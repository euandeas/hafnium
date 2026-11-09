# Kansora: shared kickstart (repos, branding, post-install). Included by kansora.ks
# and kansora-nvidia.ks. Run `just ks` to flatten and validate.
#
# The kickstart only sets the package set. Language, keyboard, timezone, disk
# and user stay interactive in Anaconda, as on a normal Fedora netinstall.

# --- Repositories (installer-time) -------------------------------------------
# The same repos are kept on the installed system by the kansora-repos package.
url  --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"
repo --name=updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch"
repo --name=kansora --baseurl="https://euandeas.github.io/kansora/repo/"
repo --name=duxlabs-dms --baseurl="https://download.copr.fedorainfracloud.org/results/duxlabs/dms/fedora-$releasever-$basearch/"
repo --name=duxlabs-dux-repo --baseurl="https://download.copr.fedorainfracloud.org/results/duxlabs/dux-repo/fedora-$releasever-$basearch/"
repo --name=rpmfusion-free --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch"
repo --name=rpmfusion-free-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch"
repo --name=rpmfusion-nonfree --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch"
repo --name=rpmfusion-nonfree-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch"
repo --name=terra --baseurl="https://repos.fyralabs.com/terra$releasever" --cost=100

# --- System ------------------------------------------------------------------
network --hostname=kansora
firewall --enabled --service=mdns
selinux --enforcing
services --enabled=greetd,NetworkManager,systemd-resolved,dnf5-automatic.timer --disabled=NetworkManager-wait-online,flatpak-add-fedora-repos
xconfig --startxonboot

# --- Post-install ------------------------------------------------------------
%post --erroronfail --log=/root/kansora-ks-post.log
set -euxo pipefail

# The kansora RPM's %post does this on first install. Repeat it here so a
# scriptlet that was skipped in the installer chroot doesn't leave a text-only boot.
systemctl set-default graphical.target
systemctl enable greetd.service kansora-flathub.service
systemctl --global enable kansora-dots.service dms.service dsearch.service

# Quiet boot: hidden GRUB menu, Flexoki Plymouth splash.
# The kansora package already selects the theme while installing, before the
# installer builds the initramfs, so no rebuild is needed here. (Never use
# `plymouth-set-default-theme -R` in the chroot: it rebuilds for the installer's kernel.)
grub2-editenv - set menu_auto_hide=1
plymouth-set-default-theme kansora
%end
