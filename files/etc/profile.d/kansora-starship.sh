# shellcheck shell=sh
# Kansora: Starship prompt for interactive bash shells (https://starship.rs).
# Configure it in ~/.config/starship.toml. To turn it off for your user, add
# `export KANSORA_NO_STARSHIP=1` to ~/.bashrc before it sources /etc/bashrc.
if [ -n "${BASH_VERSION:-}" ] && [ -z "${KANSORA_NO_STARSHIP:-}" ] && command -v starship >/dev/null 2>&1; then
    case $- in
        *i*) eval "$(starship init bash)" ;;
    esac
fi
