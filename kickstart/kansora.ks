# Kansora: AMD / Intel graphics
%include kansora-common.ks

# Fedora Custom Operating System + Common NetworkManager Submodules + Standard
%packages
@^custom-environment
@networkmanager-submodules
@standard
kansora
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
%end
