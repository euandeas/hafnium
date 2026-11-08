# Hafnium helper recipes, run through /usr/bin/hafnium (`hafnium help` lists them).

[private]
default:
    @hafnium

# Update the whole system: dnf (which includes Hafnium and hdots), flatpaks, firmware
update:
    #!/usr/bin/bash
    set -euo pipefail
    sudo dnf upgrade --refresh
    if command -v flatpak >/dev/null; then flatpak update -y; fi
    if command -v fwupdmgr >/dev/null; then fwupdmgr refresh --force >/dev/null || :; fwupdmgr update || :; fi

# Upgrade to the next Fedora release (or RELEASE), once every repo Hafnium uses has it
upgrade-fedora RELEASE="":
    #!/usr/bin/bash
    set -euo pipefail
    current="$(rpm -E %fedora)"
    target="{{ RELEASE }}"
    target="${target:-$((current + 1))}"
    if ((target <= current)); then
        echo "Already on Fedora ${current}."
        exit 0
    fi

    echo "Checking that Hafnium's repos have Fedora ${target}:"
    missing=0
    mirrors() { curl -fsSL --max-time 20 "$1" 2>/dev/null | grep -qE '^https?://'; }
    repomd() { [[ "$(curl -sL -o /dev/null -w '%{http_code}' --max-time 20 "$1")" == 200 ]]; }
    check() {
        local name="$1"; shift
        if "$@"; then echo "  ✓ ${name}"; else echo "  ✗ ${name}"; missing=1; fi
    }
    check "Fedora"              mirrors "https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-${target}&arch=x86_64"
    check "RPM Fusion free"     mirrors "https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-${target}&arch=x86_64"
    check "RPM Fusion nonfree"  mirrors "https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-${target}&arch=x86_64"
    check "Terra"               repomd  "https://repos.fyralabs.com/terra${target}/repodata/repomd.xml"
    check "Dux (dms)"           repomd  "https://download.copr.fedorainfracloud.org/results/duxlabs/dms/fedora-${target}-x86_64/repodata/repomd.xml"
    check "Dux (dux-repo)"      repomd  "https://download.copr.fedorainfracloud.org/results/duxlabs/dux-repo/fedora-${target}-x86_64/repodata/repomd.xml"

    if ((missing)); then
        echo
        echo "Not every repo has Fedora ${target} yet. Upgrading now would leave packages without updates or break dependencies; try again later."
        exit 1
    fi

    echo
    read -r -p "Upgrade from Fedora ${current} to ${target}? [y/N] " ok
    [[ "$ok" =~ ^[Yy] ]] || exit 0
    sudo dnf upgrade --refresh -y
    sudo dnf system-upgrade download --releasever="${target}"
    echo
    read -r -p "Download finished. Reboot now to install the upgrade? [y/N] " ok
    if [[ "$ok" =~ ^[Yy] ]]; then
        sudo dnf system-upgrade reboot
    else
        echo "Run 'sudo dnf system-upgrade reboot' when you're ready."
    fi

# Deploy any missing dotfiles (Hafnium defaults plus your mise dotfiles). Never overwrites.
update-dotfiles:
    hafnium-dots apply

# Show dotfile state
dotfiles-status:
    hafnium-dots status

# Restore one dotfile to its default, e.g. `hafnium reset-dotfile ~/.config/ghostty/config`
reset-dotfile TARGET:
    hafnium-dots reset "{{ TARGET }}"

# Restore every Hafnium dotfile to its default
reset-all-dotfiles:
    hafnium-dots reset-all

# Turn the login-time dotfile service on or off
toggle-dotfiles-service:
    #!/usr/bin/bash
    if systemctl --user is-enabled --quiet hafnium-dots.service; then
        systemctl --user disable hafnium-dots.service && echo "Disabled automatic dotfile deployment"
    else
        systemctl --user enable hafnium-dots.service && echo "Enabled automatic dotfile deployment"
    fi

# Copy your DMS theme and wallpaper to the login screen
sync-greeter:
    dms-greeter sync

# Bootstrap a personal mise dotfiles repo on top of Hafnium (e.g. `hafnium bootstrap-dotfiles euandeas/.dotfiles`)
bootstrap-dotfiles REPO:
    #!/usr/bin/bash
    set -euo pipefail
    repo="{{ REPO }}"
    [[ "$repo" == *://* || "$repo" == git@* ]] || repo="https://github.com/${repo}.git"
    # --force-dotfiles: replace the stock ~/.bashrc and the Hafnium seeds your repo overrides
    mise bootstrap --from "$repo" --from-dir "$HOME/.dotfiles" --config-dir . --force-dotfiles

# Enrol the akmods signing key so NVIDIA modules load with Secure Boot on (NVIDIA ISO)
enroll-secure-boot-key:
    #!/usr/bin/bash
    set -euo pipefail
    key=/etc/pki/akmods/certs/public_key.der
    if [[ ! -e "$key" ]]; then
        echo "No akmods key found. Is this the NVIDIA image?" >&2
        exit 1
    fi
    echo "Choose a one-time password. At the next boot, pick 'Enroll MOK' and enter it."
    sudo mokutil --import "$key"
