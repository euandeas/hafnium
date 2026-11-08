# Defaults

## Packages

| Package | Ships |
|---|---|
| `hafnium` | The desktop: niri, DMS, dms-greeter on greetd, Ghostty, Dux Files, PipeWire, Flatpak, mise. Also the system defaults below and the `hafnium` command |
| `hafnium-repos` | Repo files for this repo's package repo and the Dux COPRs; pulls in the RPM Fusion and Terra release packages |
| `hafnium-codecs` | `ffmpeg`, GStreamer codecs, `mesa-va-drivers-freeworld` |
| `hafnium-nvidia` | `akmod-nvidia` from RPM Fusion, nouveau blacklist, early KMS |
| `hafnium-dots` | Default dotfiles ([hdots](https://github.com/euandeas/hdots)) |

## System defaults

Everything lives under `/usr`, so it can be overridden from `/etc`.

| Default | File | Override |
|---|---|---|
| DNS: Cloudflare over TLS, Quad9 fallback | [`resolved.conf.d/90-hafnium-dns.conf`](../files/usr/lib/systemd/resolved.conf.d/90-hafnium-dns.conf) | `/etc/systemd/resolved.conf.d/` |
| dnf: 10 parallel downloads | [`libdnf.conf.d/80-hafnium.conf`](../files/usr/share/dnf5/libdnf.conf.d/80-hafnium.conf) | `/etc/dnf/libdnf5.conf.d/` |
| Automatic updates | [`dnf5-automatic.service.d`](../files/usr/lib/systemd/system/dnf5-automatic.service.d/50-hafnium.conf) | `systemctl disable dnf5-automatic.timer` |
| Login screen | [`greetd/config.toml`](../files/usr/share/hafnium/greetd/config.toml), copied to `/etc/greetd/config.toml` only if that isn't already set up for dms-greeter | edit `/etc/greetd/config.toml`, or `dms-greeter sync` (auto-login, fingerprint) |
| Boot splash | [`plymouth/themes/hafnium`](../files/usr/share/plymouth/themes/hafnium/hafnium.plymouth) | `plymouth-set-default-theme -R spinner` |
| Default terminal | [`niri-xdg-terminals.list`](../files/usr/share/xdg-terminal-exec/niri-xdg-terminals.list) | `~/.config/xdg-terminals.list` |
| Icon theme (Papirus-Dark) | [`90_hafnium.gschema.override`](../files/usr/share/glib-2.0/schemas/90_hafnium.gschema.override) | `gsettings set org.gnome.desktop.interface icon-theme <name>`, or DMS settings |
| Monospace font (CommitMono Nerd Font Mono) | [`50-hafnium-monospace.conf`](../files/usr/share/fontconfig/conf.avail/50-hafnium-monospace.conf), plus `monospace-font-name` in the gschema override | `~/.config/fontconfig/fonts.conf`, `gsettings set org.gnome.desktop.interface monospace-font-name <font>` |
| fastfetch layout (Fedora logo, Hafnium and DMS versions) | `/etc/xdg/fastfetch/config.jsonc` from [hdots](https://github.com/euandeas/hdots) | `~/.config/fastfetch/config.jsonc` |
| Starship prompt (bash) | [`hafnium-starship.sh`](../files/etc/profile.d/hafnium-starship.sh) | `export HAFNIUM_NO_STARSHIP=1` in `~/.bashrc`, config in `~/.config/starship.toml` |
| File manager (Dux Files) | [`niri-mimeapps.list`](../files/usr/share/applications/niri-mimeapps.list) | `~/.config/mimeapps.list` |
| File chooser (Dux Files) | [`niri-portals.conf`](../files/etc/xdg/xdg-desktop-portal/niri-portals.conf) | edit it, or `~/.config/xdg-desktop-portal/niri-portals.conf` |
| Services | [`80-hafnium.preset`](../files/usr/lib/systemd/system-preset/80-hafnium.preset) | `systemctl enable`/`disable` |

The GRUB menu is hidden (`grub2-editenv - unset menu_auto_hide` brings it back), and
Fedora's own flatpak remote is disabled in favour of Flathub.
