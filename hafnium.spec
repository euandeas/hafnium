Name:           hafnium
Version:        0.1.0
# The Makefile rewrites Release to <commit-count>.git<sha> so every push upgrades.
Release:        1%{?dist}
Summary:        Hafnium: a minimal Fedora desktop with niri and Dux (DMS)
License:        Apache-2.0
URL:            https://github.com/euandeas/hafnium
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  systemd-rpm-macros

Requires:       hafnium-repos = %{version}-%{release}
Requires:       hafnium-dots
Requires:       hafnium-codecs = %{version}-%{release}

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
Requires:       dux-greeter
Requires:       greetd
Requires:       greetd-selinux

# --- Default apps: Ghostty is the default terminal -----------------------------
Requires:       ghostty
Requires:       xdg-terminal-exec
Requires:       nautilus

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
Requires:       default-fonts
Requires:       adwaita-sans-fonts
Requires:       google-noto-color-emoji-fonts

# --- System defaults: auto-updates, quiet boot -------------------------------
Requires:       dnf5-plugin-automatic
Requires:       plymouth
Requires:       plymouth-plugin-two-step
Requires:       plymouth-theme-spinner
Requires:       systemd-resolved

# --- Tooling -------------------------------------------------------------------
Requires:       mise
Requires:       git-core
Requires:       just

%description
Hafnium is a minimal, non-atomic Fedora desktop built on niri and the Dux
Modular Shell (DMS), with Ghostty as the default terminal. This metapackage
pulls in the desktop and ships Hafnium's system configuration: greetd with
dms-greeter, encrypted DNS, dnf tuning and automatic updates, the Flexoki light and dark themes
and wallpapers, a quiet Flexoki boot splash, presets, the default terminal, and the hjust helper.

%package repos
Summary:        Package repositories used by Hafnium
Requires:       rpmfusion-free-release
Requires:       rpmfusion-nonfree-release
Requires:       terra-release
%description repos
dnf repository definitions for Hafnium's own repo (GitHub Pages) and the Dux (duxlabs) COPRs,
plus the RPM Fusion and Terra release packages.

%package codecs
Summary:        Full multimedia codecs for Hafnium (RPM Fusion)
Requires:       hafnium-repos = %{version}-%{release}
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
Summary:        NVIDIA driver setup for Hafnium (RPM Fusion akmod)
Requires:       hafnium = %{version}-%{release}
Requires:       akmod-nvidia
Requires:       xorg-x11-drv-nvidia-cuda
Requires:       xorg-x11-drv-nvidia-power
Requires:       libva-nvidia-driver
Requires:       mokutil
%description nvidia
Proprietary NVIDIA driver from RPM Fusion (akmod), plus Hafnium's modprobe and
dracut defaults for niri on NVIDIA. Needs the RPM Fusion free and nonfree repos.

%prep
%autosetup -n %{name}-%{version}

%build

%install
cp -a files/. %{buildroot}/
install -d %{buildroot}%{_sysconfdir}/yum.repos.d
install -pm0644 repos/*.repo %{buildroot}%{_sysconfdir}/yum.repos.d/
cp -a nvidia/. %{buildroot}/

%post
%systemd_post hafnium-flathub.service
if [ "$1" -eq 1 ]; then
    # First install: boot to the greeter and enable Hafnium's presets.
    systemctl preset greetd.service power-profiles-daemon.service bluetooth.service \
        dnf5-automatic.timer systemd-resolved.service NetworkManager-wait-online.service \
        flatpak-add-fedora-repos.service >/dev/null 2>&1 || :
    systemctl --global preset dms.service dsearch.service >/dev/null 2>&1 || :
    systemctl set-default graphical.target >/dev/null 2>&1 || :
    # Quiet boot: Flexoki splash (the initramfs is rebuilt by the kickstart / next kernel)
    plymouth-set-default-theme hafnium >/dev/null 2>&1 || :
    grub2-editenv - set menu_auto_hide=1 >/dev/null 2>&1 || :
fi

%preun
%systemd_preun hafnium-flathub.service

%postun
%systemd_postun hafnium-flathub.service

%post nvidia
if [ "$1" -eq 1 ]; then
    systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service >/dev/null 2>&1 || :
fi

%files
%doc README.md
%{_bindir}/hjust
%{_unitdir}/hafnium-flathub.service
%dir %{_unitdir}/greetd.service.d
%{_unitdir}/greetd.service.d/50-hafnium.conf
%{_presetdir}/80-hafnium.preset
%{_userpresetdir}/80-hafnium.preset
%{_prefix}/lib/environment.d/60-hafnium.conf
%dir %{_datadir}/hafnium
%{_datadir}/hafnium/just/
%{_datadir}/hafnium/greetd/
%{_datadir}/xdg-terminal-exec/niri-xdg-terminals.list
%dir %{_datadir}/dms
%{_datadir}/dms/cli-policy.json
%{_prefix}/lib/systemd/resolved.conf.d/90-hafnium-dns.conf
%dir %{_unitdir}/dnf5-automatic.service.d
%{_unitdir}/dnf5-automatic.service.d/50-hafnium.conf
%{_datadir}/dnf5/libdnf.conf.d/80-hafnium.conf
%{_datadir}/plymouth/themes/hafnium/
%{_datadir}/hafnium/themes/
%{_datadir}/backgrounds/hafnium/
%{_tmpfilesdir}/hafnium-greeter.conf

%files repos
%config(noreplace) %{_sysconfdir}/yum.repos.d/*.repo

%files codecs
# metapackage

%files nvidia
%{_modprobedir}/hafnium-nvidia.conf
%{_prefix}/lib/dracut/dracut.conf.d/90-hafnium-nvidia.conf

%changelog
* Sun Nov 08 2026 euandeas - 0.1.0-1
- Initial package
