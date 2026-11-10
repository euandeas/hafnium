# Kansora

A minimal Fedora 45 desktop with [niri](https://niri-wm.github.io/niri/),
[Dux](https://duxlabs.dev/) (DMS) and [Ghostty](https://ghostty.org).
It's a normal dnf-managed install, not an image, inspired by
[Zirconium](https://github.com/zirconium-dev/zirconium).

## Install

Download `kansora-live-45-x86_64.iso` from [Releases](../../releases/tag/latest),
write it to a USB stick and boot it. It starts a live Kansora session; open the
launcher (Mod+Space) and choose **Install to Hard Drive**. No internet needed.

**NVIDIA:** the live session and a fresh install use the open nouveau driver. Run
`kansora enable-nvidia` after installing to switch to NVIDIA's driver (it handles
Secure Boot too).

## What you get

- Fedora Custom OS + `@standard` + `@networkmanager-submodules`
- niri, DMS, the dms-greeter login screen, Ghostty, Dux Files, Flatpak (Flathub), mise
- RPM Fusion, Terra, full codecs, printing (CUPS), encrypted DNS, automatic updates, a quiet boot
- Flexoki light/dark theme and wallpapers, Papirus icons, Commit Mono, the Starship prompt
- Default dotfiles from [kdots](https://github.com/euandeas/kdots)

No apps beyond that. Add your own with a mise dotfiles repo:

```sh
kansora bootstrap-dotfiles euandeas/.dotfiles
```

See [docs/defaults.md](docs/defaults.md) for what each package ships and how to
override it.

## Using it

```sh
kansora                 # overview: versions, update and reboot status, common commands
kansora help            # every command
kansora update          # dnf + flatpak + firmware
kansora sync-greeter    # copy your DMS theme to the login screen
kansora upgrade-fedora  # move to the next Fedora release once all repos support it
```

Put niri changes in `~/.config/niri/local.kdl`.

## Building

```sh
just check           # run the CI checks locally (needs ../kdots and podman)
just live-container  # build the live ISO
just vm              # boot it in a VM
```

See [docs/building.md](docs/building.md) for the workflows and package repo.
