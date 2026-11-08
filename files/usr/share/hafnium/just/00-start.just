# hjust: Hafnium helper recipes. Run `hjust` to pick one.

default:
    @hjust --choose

# Update the whole system: dnf (which includes Hafnium and hdots), flatpaks, firmware
update:
    #!/usr/bin/bash
    set -euo pipefail
    sudo dnf upgrade --refresh
    if command -v flatpak >/dev/null; then flatpak update -y; fi
    if command -v fwupdmgr >/dev/null; then fwupdmgr refresh --force >/dev/null || :; fwupdmgr update || :; fi

# Deploy any missing dotfiles (Hafnium defaults plus your mise dotfiles). Never overwrites.
update-dotfiles:
    hafnium-dots apply

# Show dotfile state
dotfiles-status:
    hafnium-dots status

# Restore one dotfile to its default, e.g. `hjust reset-dotfile ~/.config/ghostty/config`
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

# Bootstrap a personal mise dotfiles repo on top of Hafnium (e.g. `hjust bootstrap-dotfiles euandeas/.dotfiles`)
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
