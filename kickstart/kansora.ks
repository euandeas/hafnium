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
%end
