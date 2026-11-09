# Kansora: NVIDIA graphics (proprietary driver from RPM Fusion, built with akmods)
%include kansora-common.ks

# Fedora Custom Operating System + Common NetworkManager Submodules + Standard
%packages
@^custom-environment
@networkmanager-submodules
@standard
kansora
kansora-nvidia
kernel-devel
# Codecs from RPM Fusion: swap Fedora's ffmpeg-free and mesa VA-API for the full builds
@multimedia
-PackageKit-gstreamer-plugin
-ffmpeg-free
-mesa-va-drivers
# Recommended by niri, but DMS already provides the launcher, lock screen and bar,
# and Ghostty is the terminal
-alacritty
-fuzzel
-swaylock
-waybar
# Server-oriented parts of @standard that a desktop doesn't need (Zirconium skips
# them too): support reports (sos pulls ~140 MiB of AWS libraries), a second
# "rescue" boot image built during install, enterprise login (sssd, realmd),
# PackageKit, crash reporting, syslog, SELinux alert GUI, process accounting.
-sos
-dracut-config-rescue
-sssd*
-realmd
-PackageKit
-PackageKit-glib
-abrt*
-rsyslog
-setroubleshoot*
-mcelog
-psacct
-plocate
-cyrus-sasl-plain
-iptstate
-pinfo
# Unused here: NetworkManager handles networking; network debugging tools; dnf5
# doesn't use deltarpm
-systemd-networkd
-tcpdump
-traceroute
-mtr
-at
-bc
-dos2unix
-deltarpm
# nouveau's firmware: nouveau is blacklisted here and the NVIDIA driver ships its own
-nvidia-gpu-firmware
%end

%post --erroronfail --log=/root/kansora-nvidia-post.log
set -euxo pipefail

# Build the NVIDIA module now so the first boot doesn't fall back to nouveau or
# sit on a black screen while akmods compiles.
KVER="$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | sort -V | tail -n1)"
akmods --force --kernels "${KVER}" || echo "akmods build failed; akmods.service will retry at boot"
dracut --force --kver "${KVER}"   # add the freshly built driver to the initramfs (theme already set)

# Secure Boot: modules are signed with a key akmods generated on this machine.
# It must be enrolled once with `kansora enroll-secure-boot-key`.
%end
