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
# Recommended by DMS for its audio visualiser
-cava
%end

%post --erroronfail --log=/root/kansora-nvidia-post.log
set -euxo pipefail

# Build the NVIDIA module now so the first boot doesn't fall back to nouveau or
# sit on a black screen while akmods compiles.
KVER="$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | sort -V | tail -n1)"
akmods --force --kernels "${KVER}" || echo "akmods build failed; akmods.service will retry at boot"
dracut --force --kver "${KVER}"   # runs after the common %post, so the Plymouth theme is kept

# Secure Boot: modules are signed with a key akmods generated on this machine.
# It must be enrolled once with `kansora enroll-secure-boot-key`.
%end
