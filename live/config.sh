#!/bin/bash
# kiwi runs this inside the image after installing packages. Most of Kansora's
# setup already happens in the kansora package's scriptlets (presets, greetd,
# boot splash, GRUB menu); this covers what only an image build needs.
set -euxo pipefail

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

# Each installed machine makes its own identity
rm -f /etc/machine-id
echo 'uninitialized' > /etc/machine-id
rm -f /var/lib/systemd/random-seed

# Match Fedora's GRUB settings (kiwi issue 2198, no submenus or recovery entries)
echo "GRUB_DEFAULT=saved" >> /etc/default/grub
echo "GRUB_DISABLE_SUBMENU=true" >> /etc/default/grub
echo "GRUB_DISABLE_RECOVERY=true" >> /etc/default/grub

# No root password (users are created in the installer)
passwd -d root
passwd -l root

# Live session: livesys runs /usr/libexec/livesys/sessions.d/livesys-niri
echo 'livesys_session="niri"' > /etc/sysconfig/livesys

# Services: greeter, networking, encrypted DNS, automatic updates
systemctl set-default graphical.target
systemctl enable greetd.service NetworkManager.service systemd-resolved.service dnf5-automatic.timer
systemctl disable NetworkManager-wait-online.service flatpak-add-fedora-repos.service || :
