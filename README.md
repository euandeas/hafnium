# Kansora

A minimal Fedora 45 desktop with [niri](https://niri-wm.github.io/niri/),
[Dux](https://duxlabs.dev/) (DMS) and [Ghostty](https://ghostty.org).
It's a normal dnf-managed install, not an image, inspired by
[Zirconium](https://github.com/zirconium-dev/zirconium).

## Install

Download an ISO from [Releases](../../releases/tag/latest):

- `kansora-45-x86_64.iso`: AMD / Intel
- `kansora-nvidia-45-x86_64.iso`: NVIDIA

Write it to a USB stick and boot it. Anaconda asks for disk, language and user as
usual. The rest is set by the kickstart, and it needs internet access.

**NVIDIA with Secure Boot:** run `kansora enroll-secure-boot-key` once, reboot and
choose *Enroll MOK*.

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
kansora                 # overview: versions and common commands
kansora help            # every command
kansora update          # dnf + flatpak + firmware
kansora sync-greeter    # copy your DMS theme to the login screen
kansora upgrade-fedora  # move to the next Fedora release once all repos support it
```

Put niri changes in `~/.config/niri/local.kdl`.

## Building

```sh
just check                  # run the CI checks locally (needs ../kdots and podman)
just iso-container kansora  # build an ISO
```

See [docs/building.md](docs/building.md) for the workflows and package repo.
