# Kansora's os-release, in Fedora's release-identity slot.
#
# Fedora splits its release package in three: fedora-release (system-release,
# $releasever), fedora-release-common (macros, presets, /etc/fedora-release) and
# one fedora-release-identity-* package that owns /usr/lib/os-release. This is
# that identity package for Kansora, so os-release reads Kansora while
# everything else stays Fedora's and `rpm -V fedora-release-common` stays clean.
#
# fedora-release-common requires an identity of its *exact* version-release, so
# this is built per Fedora release by build-scripts/build-repo, which passes:
#   fedora_version  e.g. 45
#   fedora_release  Fedora's release-package Release, e.g. 14
#   kansora_build   the kansora commit count, so rebuilds still upgrade
# and Fedora's own os-release for that release as Source0.

Name:           kansora-release-identity
Version:        %{fedora_version}
Release:        %{fedora_release}.%{kansora_build}
Summary:        Kansora identity (os-release) for Fedora %{fedora_version}
License:        MIT
URL:            https://github.com/euandeas/kansora
Source0:        fedora-os-release
BuildArch:      noarch

Provides:       fedora-release-identity = %{fedora_version}-%{fedora_release}
Conflicts:      fedora-release-identity
# Replace Fedora's basic identity on upgrade. Versioned, so a newer Fedora
# identity (from a Fedora update this hasn't been rebuilt for yet) isn't hidden.
Obsoletes:      fedora-release-identity-basic <= %{fedora_version}-%{fedora_release}

%description
Kansora's /usr/lib/os-release: NAME, PRETTY_NAME, VARIANT, LOGO and the project
URLs are Kansora's, while ID=fedora, VERSION_ID, CPE_NAME and SUPPORT_END stay
Fedora's, so tools that check for Fedora (dnf copr, Anaconda, scripts) keep
working.

%prep

%build
# Start from Fedora's os-release for this release and change only what is
# Kansora's. Unknown keys pass through untouched.
sed -E \
    -e 's|^NAME=.*|NAME="Kansora"|' \
    -e 's|^VERSION=.*|VERSION="%{fedora_version}"|' \
    -e 's|^PRETTY_NAME=.*|PRETTY_NAME="Kansora %{fedora_version}"|' \
    -e 's|^ANSI_COLOR=.*|ANSI_COLOR="0;38;2;67;133;190"|' \
    -e 's|^LOGO=.*|LOGO=kansora|' \
    -e 's|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="kansora"|' \
    -e 's|^HOME_URL=.*|HOME_URL="https://github.com/euandeas/kansora"|' \
    -e 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/euandeas/kansora#readme"|' \
    -e 's|^SUPPORT_URL=.*|SUPPORT_URL="https://github.com/euandeas/kansora/issues"|' \
    -e 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="https://github.com/euandeas/kansora/issues"|' \
    -e '/^(REDHAT_|VARIANT)/d' \
    %{SOURCE0} > os-release
printf 'VARIANT="Kansora"\nVARIANT_ID=kansora\n' >> os-release
# Must still say Fedora where it matters
grep -qx 'ID=fedora' os-release
grep -qx 'VERSION_ID=%{fedora_version}' os-release
grep -qx 'NAME="Kansora"' os-release

%install
install -Dpm0644 os-release %{buildroot}%{_prefix}/lib/os-release

%files
%{_prefix}/lib/os-release
