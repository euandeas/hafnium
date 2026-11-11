Name:           kansora
Version:        0.2.0
# The Makefile rewrites Release to <commit-count>.git<sha> so every push upgrades.
Release:        1%{?dist}
Summary:        Kansora: a minimal Fedora desktop with niri and Dux (DMS)
License:        Apache-2.0
URL:            https://github.com/euandeas/kansora
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  systemd-rpm-macros

# Renamed from Hafnium in 0.2.0: replace the old packages on upgrade
Obsoletes:      hafnium < 0.2
Provides:       hafnium = %{version}-%{release}

Requires:       kansora-repos = %{version}-%{release}
Requires:       kansora-dots
Requires:       kansora-codecs = %{version}-%{release}
# os-release says Kansora (built per Fedora release: identity/kansora-release-identity.spec)
Requires:       kansora-release-identity

# --- Compositor and session ----------------------------------------------------
Requires:       niri
Requires:       xwayland-satellite
Requires:       xdg-desktop-portal-gnome
Requires:       xdg-desktop-portal-gtk
Requires:       gnome-keyring
Requires:       gnome-keyring-pam
Requires:       mesa-dri-drivers
Requires:       mesa-vulkan-drivers

# --- Dux (DMS shell, launcher search, system monitor, login screen) ------------
Requires:       dms
Requires:       quickshell
Requires:       dux-search
Requires:       dux-gop
Requires:       matugen
Requires:       accountsservice
# Optional DMS features (see `dms doctor`): audio visualiser, more wallpaper image formats
Requires:       cava
Requires:       kf6-kimageformats
Requires:       dux-greeter
Requires:       greetd
Requires:       greetd-selinux

# --- Default apps: Ghostty is the default terminal -----------------------------
Requires:       ghostty
Requires:       xdg-terminal-exec
Requires:       dux-files

# --- Printing: CUPS (socket-activated), printer management from DMS, USB auto-setup,
# .local printer hostnames. Vendor drivers (hplip, gutenprint-cups...) are per machine.
Requires:       cups
Requires:       cups-pk-helper
Requires:       system-config-printer-udev
Requires:       nss-mdns

# --- Audio, Bluetooth, power ---------------------------------------------------
Requires:       pipewire
Requires:       pipewire-pulseaudio
Requires:       wireplumber
Requires:       bluez
Requires:       power-profiles-daemon

# --- Desktop plumbing ----------------------------------------------------------
Requires:       brightnessctl
Requires:       playerctl
Requires:       wl-clipboard
Requires:       xdg-user-dirs
Requires:       xdg-utils
Requires:       flatpak
Requires:       adw-gtk3-theme
Requires:       papirus-icon-theme
Requires:       default-fonts
Requires:       adwaita-sans-fonts
Requires:       commitmono-nerd-fonts
Requires:       google-noto-color-emoji-fonts

# --- System defaults: auto-updates, quiet boot -------------------------------
Requires:       dnf5-plugin-automatic
Requires:       plymouth
Requires:       plymouth-plugin-two-step
Requires:       plymouth-theme-spinner
Requires:       hicolor-icon-theme
Requires:       systemd-resolved

# --- Tooling -------------------------------------------------------------------
Requires:       mise
Requires:       git-core
Requires:       just
Requires:       starship

%description
Kansora is a minimal, non-atomic Fedora desktop built on niri and the Dux
Modular Shell (DMS), with Ghostty as the default terminal. This metapackage
pulls in the desktop and ships Kansora's system configuration: greetd with
dms-greeter, encrypted DNS, dnf tuning and automatic updates, the Flexoki light and dark themes
and wallpapers, a quiet Flexoki boot splash, presets, the default terminal, and the kansora helper command.

%package repos
Summary:        Package repositories used by Kansora
# Renamed from Hafnium in 0.2.0: replace the old packages on upgrade
Obsoletes:      hafnium-repos < 0.2
Provides:       hafnium-repos = %{version}-%{release}
Requires:       rpmfusion-free-release
Requires:       rpmfusion-nonfree-release
Requires:       terra-release
%description repos
dnf repository definitions for Kansora's own repo (GitHub Pages) and the Dux (duxlabs) COPRs,
plus the RPM Fusion and Terra release packages.

%package codecs
Summary:        Full multimedia codecs for Kansora (RPM Fusion)
# Renamed from Hafnium in 0.2.0: replace the old packages on upgrade
Obsoletes:      hafnium-codecs < 0.2
Provides:       hafnium-codecs = %{version}-%{release}
Requires:       kansora-repos = %{version}-%{release}
Requires:       ffmpeg
Requires:       gstreamer1-plugin-libav
Requires:       gstreamer1-plugin-openh264
Requires:       gstreamer1-plugins-bad-freeworld
Requires:       gstreamer1-plugins-ugly
Requires:       mesa-va-drivers-freeworld
%description codecs
Full ffmpeg, GStreamer codecs and hardware video decoding (VA-API) for AMD and
Intel from RPM Fusion. Replaces Fedora's ffmpeg-free.

%package nvidia
Summary:        NVIDIA driver setup for Kansora (RPM Fusion akmod)
# Renamed from Hafnium in 0.2.0: replace the old packages on upgrade
Obsoletes:      hafnium-nvidia < 0.2
Provides:       hafnium-nvidia = %{version}-%{release}
Requires:       kansora = %{version}-%{release}
Requires:       akmod-nvidia
Requires:       xorg-x11-drv-nvidia-cuda
Requires:       xorg-x11-drv-nvidia-power
Requires:       libva-nvidia-driver
Requires:       mokutil
%description nvidia
Proprietary NVIDIA driver from RPM Fusion (akmod), plus Kansora's modprobe and
dracut defaults for niri on NVIDIA. Needs the RPM Fusion free and nonfree repos.

%package live
Summary:        Live ISO session for Kansora
Requires:       kansora = %{version}-%{release}
Requires:       livesys-scripts
# Owners of the profile and branding directories
Requires:       anaconda-core
Requires:       cockpit-ws
%description live
The livesys handler for Kansora's live ISO: logs liveuser into niri through
greetd and shows the installer in the DMS launcher. Only the live image installs
this, and it does nothing outside a live boot.

%prep
%autosetup -n %{name}-%{version}

%build

%install
cp -a files/. %{buildroot}/
install -d %{buildroot}%{_sysconfdir}/yum.repos.d
install -pm0644 repos/*.repo %{buildroot}%{_sysconfdir}/yum.repos.d/
cp -a nvidia/. %{buildroot}/
cp -a files-live/. %{buildroot}/
install -d %{buildroot}%{_sysconfdir}/fonts/conf.d
ln -s ../../..%{_datadir}/fontconfig/conf.avail/50-kansora-monospace.conf \
    %{buildroot}%{_sysconfdir}/fonts/conf.d/50-kansora-monospace.conf

%post
%systemd_post kansora-flathub.service
# Every install and upgrade: point greetd at dms-greeter unless it already is.
%{_libexecdir}/kansora/setup-greetd || :
if [ "$1" -eq 1 ]; then
    # First install: boot to the greeter and enable Kansora's presets.
    systemctl preset greetd.service power-profiles-daemon.service bluetooth.service \
        dnf5-automatic.timer systemd-resolved.service NetworkManager-wait-online.service \
        flatpak-add-fedora-repos.service >/dev/null 2>&1 || :
    systemctl --global preset dms.service dsearch.service >/dev/null 2>&1 || :
    systemctl set-default graphical.target >/dev/null 2>&1 || :
    # Quiet boot: Flexoki splash, picked up by the next initramfs build
    plymouth-set-default-theme kansora >/dev/null 2>&1 || :
    grub2-editenv - set menu_auto_hide=1 >/dev/null 2>&1 || :
fi

%preun
%systemd_preun kansora-flathub.service

%postun
%systemd_postun kansora-flathub.service

%post nvidia
if [ "$1" -eq 1 ]; then
    systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service >/dev/null 2>&1 || :
fi

%files
%doc README.md
%{_bindir}/kansora
%{_unitdir}/kansora-flathub.service
%dir %{_libexecdir}/kansora
%{_libexecdir}/kansora/setup-greetd
%{_presetdir}/80-kansora.preset
%{_userpresetdir}/80-kansora.preset
%{_prefix}/lib/environment.d/60-kansora.conf
%dir %{_datadir}/kansora
%{_datadir}/kansora/just/
%{_datadir}/kansora/greetd/
%{_datadir}/xdg-terminal-exec/niri-xdg-terminals.list
%{_datadir}/applications/niri-mimeapps.list
%{_datadir}/glib-2.0/schemas/90_kansora.gschema.override
%{_datadir}/fontconfig/conf.avail/50-kansora-monospace.conf
%{_sysconfdir}/fonts/conf.d/50-kansora-monospace.conf
%config(noreplace) %{_sysconfdir}/profile.d/kansora-starship.sh
%config(noreplace) %{_sysconfdir}/xdg/xdg-desktop-portal/niri-portals.conf
%dir %{_datadir}/dms
%{_datadir}/dms/cli-policy.json
%{_prefix}/lib/systemd/resolved.conf.d/90-kansora-dns.conf
%dir %{_unitdir}/dnf5-automatic.service.d
%{_unitdir}/dnf5-automatic.service.d/50-kansora.conf
%{_datadir}/dnf5/libdnf.conf.d/80-kansora.conf
%{_datadir}/plymouth/themes/kansora/
%{_datadir}/icons/hicolor/*/apps/kansora.png
%{_datadir}/icons/hicolor/scalable/apps/kansora.svg
%{_datadir}/icons/hicolor/symbolic/apps/kansora-symbolic.svg
%{_datadir}/pixmaps/kansora.svg
%{_datadir}/kansora/themes/
%{_datadir}/kansora/branding/
%{_datadir}/backgrounds/kansora/
%{_tmpfilesdir}/kansora-greeter.conf

%files repos
%config(noreplace) %{_sysconfdir}/yum.repos.d/*.repo

%files codecs
# metapackage

%files live
%{_libexecdir}/livesys/sessions.d/livesys-niri
# Installer: Kansora profile (picked by VARIANT_ID=kansora) and web UI branding
%config(noreplace) %{_sysconfdir}/anaconda/profile.d/kansora.conf
%dir %{_datadir}/cockpit/branding/fedora-kansora
%{_datadir}/cockpit/branding/fedora-kansora/branding.css
%{_datadir}/cockpit/branding/fedora-kansora/logo.png

%files nvidia
%{_modprobedir}/kansora-nvidia.conf
%{_prefix}/lib/dracut/dracut.conf.d/90-kansora-nvidia.conf

%changelog
* Sun Nov 08 2026 euandeas - 0.1.0-1
- Initial package
