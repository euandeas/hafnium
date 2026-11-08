# Hafnium: AMD / Intel graphics
%include hafnium-common.ks

# Fedora Custom Operating System + Common NetworkManager Submodules + Standard
%packages
@^custom-environment
@networkmanager-submodules
@standard
hafnium
# Codecs from RPM Fusion: swap Fedora's ffmpeg-free and mesa VA-API for the full builds
@multimedia
-PackageKit-gstreamer-plugin
-ffmpeg-free
-mesa-va-drivers
%end
