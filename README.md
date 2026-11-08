# Hafnium

A minimal, **non-atomic** Fedora desktop with [niri](https://niri-wm.github.io/niri/)
and [Dux](https://duxlabs.dev/) (DMS), with [Ghostty](https://ghostty.org) as the
default terminal. It's inspired by [Zirconium](https://github.com/zirconium-dev/zirconium),
but Hafnium is a normal dnf-managed Fedora install rather than a bootc image, and it
keeps to the bare desktop.

Hafnium is built on **Fedora 45**. There are two ISOs:

| ISO | For |
|---|---|
| `hafnium-45-x86_64.iso` | AMD / Intel graphics |
| `hafnium-nvidia-45-x86_64.iso` | NVIDIA (proprietary driver from RPM Fusion, built with akmods) |

Download them from [Releases → latest](../../releases/tag/latest), write one to a USB
stick and boot it. The installer needs internet access. GitHub Pages must be enabled
(*Settings → Pages → Source: GitHub Actions*) and the *Build package repo* workflow
must have run, because the installer pulls the Hafnium packages from there.

## What gets installed

The package set matches a hand-picked Fedora netinstall:

- **Base environment:** Fedora Custom Operating System (`@^custom-environment`)
- **Groups:** Common NetworkManager Submodules (`@networkmanager-submodules`) and Standard (`@standard`)
- **`hafnium`:** a metapackage that adds the desktop:
  - niri, xwayland-satellite, the GNOME and GTK portals, gnome-keyring
  - DMS, quickshell, dsearch (`dux-search`), dgop (`dux-gop`), matugen, and the
    **dms-greeter** login screen on greetd
  - Ghostty (set as the default through `xdg-terminal-exec` and `$TERMINAL`), Nautilus
  - PipeWire, BlueZ, power-profiles-daemon, Flatpak (Flathub is added at first boot), mise
- **System defaults** (formerly the `sysconf/` scripts in my dotfiles):
  - **Repos:** RPM Fusion (free and nonfree), Terra and the Dux COPRs. Where two repos carry a package, dnf takes the newest version
  - **Codecs:** full `ffmpeg` and GStreamer codecs, plus `mesa-va-drivers-freeworld` (`hafnium-codecs`)
  - **DNS:** Cloudflare over TLS with Quad9 fallback, used in preference to DHCP DNS (systemd-resolved drop-in)
  - **dnf:** `max_parallel_downloads=10`, and dnf5-automatic installs updates
  - **Boot:** hidden GRUB menu, no wait for the network, Flexoki Plymouth spinner
- **Look:** the Flexoki light and dark DMS theme (`/usr/share/hafnium/themes/flexoki.json`),
  and the Flexoki orb wallpapers (`/usr/share/backgrounds/hafnium/`), which switch with
  light/dark mode. The login screen uses the same look until you run `hjust sync-greeter`.
- **`hafnium-dots`:** default dotfiles from [hdots](https://github.com/euandeas/hdots), managed by mise

Every system default lives in `/usr`, so you can override it from `/etc`:
`/etc/systemd/resolved.conf.d/`, `/etc/dnf/libdnf5.conf.d/`,
`systemctl disable dnf5-automatic.timer`, or `plymouth-set-default-theme -R spinner`.

No apps beyond these ship: no browser, office suite or Steam. Bring those in from your own
dotfiles (see [Personal setup](#personal-setup)).

## How it works

```
Fedora Everything netinstall ISO
  └─ + kickstart (mkksiso)  ─►  Anaconda installs @core/@standard/@nm-submodules + hafnium
                                                │
  GitHub Pages dnf repo ───────────────────────┤  hafnium, -repos, -codecs, -nvidia  (this repo)
  euandeas.github.io/hafnium/repo/              └  hafnium-dots                     (hdots repo)
```

- **The ISO** is the stock Fedora netinstall with [`kickstart/`](kickstart) embedded.
  The kickstart sets only the package set and repos. Language, disk, timezone and
  user are still chosen in Anaconda. The install needs internet access.
- **The system config** ships as RPMs ([`hafnium.spec`](hafnium.spec), files under
  [`files/`](files)). GitHub Actions builds them and publishes a dnf repo on this
  repo's GitHub Pages site. A `dnf upgrade` updates Hafnium itself, much as a new
  image updates Zirconium.
- **The dotfiles** layer as mise config: Hafnium's defaults sit in
  `/etc/mise/conf.d/hafnium.toml` (system layer), and your personal config in
  `~/.config/mise/config.toml` overrides them. See [hdots](https://github.com/euandeas/hdots).

| Zirconium (bootc) | Hafnium (dnf) |
|---|---|
| mkosi image, `bootc upgrade` | kickstart install, `dnf upgrade` |
| `mkosi.extra/` | `files/` in the `hafnium` RPM |
| zdots + chezmoi | hdots + mise dotfiles |
| `zjust` | `hjust` |
| negativo17 + dkms baked in | RPM Fusion `akmod-nvidia` |

### Packages

| Package | Contents |
|---|---|
| `hafnium` | Desktop metapackage; greetd drop-in → [`/usr/share/hafnium/greetd/config.toml`](files/usr/share/hafnium/greetd/config.toml); presets (greetd, dms, dsearch, dnf5-automatic; NetworkManager-wait-online off); Flathub service; Ghostty as default terminal; DMS CLI policy; `hjust`; [DNS](files/usr/lib/systemd/resolved.conf.d/90-hafnium-dns.conf), [dnf](files/usr/share/dnf5/libdnf.conf.d/80-hafnium.conf), [auto-update](files/usr/lib/systemd/system/dnf5-automatic.service.d/50-hafnium.conf) and [Plymouth](files/usr/share/plymouth/themes/hafnium/hafnium.plymouth) defaults |
| `hafnium-repos` | `.repo` files for Hafnium's GitHub Pages repo and the `duxlabs/dms` and `duxlabs/dux-repo` COPRs; pulls in `rpmfusion-{free,nonfree}-release` and `terra-release` |
| `hafnium-codecs` | `ffmpeg`, GStreamer libav/ugly/bad-freeworld/openh264, `mesa-va-drivers-freeworld` |
| `hafnium-nvidia` | `akmod-nvidia` and CUDA/VA-API/power from RPM Fusion; nouveau blacklist; `nvidia-drm modeset=1 fbdev=1`; early KMS via dracut |

## After installing

```sh
hjust                      # pick a helper recipe
hjust update               # dnf + flatpak + firmware
hjust sync-greeter         # copy your DMS theme to the login screen
```

Change niri in `~/.config/niri/local.kdl`. `~/.config/niri/config.kdl` is a managed
symlink, so don't edit it.

**NVIDIA + Secure Boot:** akmods signs the module with a key generated on your
machine. Enrol it once with `hjust enroll-secure-boot-key`, reboot, and choose
*Enroll MOK*.

## Personal setup

Add your own apps and settings with a mise bootstrap repo, e.g.
[euandeas/.dotfiles](https://github.com/euandeas/.dotfiles):

```sh
hjust bootstrap-dotfiles euandeas/.dotfiles
# = mise bootstrap --from https://github.com/euandeas/.dotfiles.git --from-dir ~/.dotfiles --config-dir . --force-dotfiles
```

## Building

```sh
just check                      # everything CI checks, in a container (needs ../hdots)
just ks                         # render and validate the kickstarts into out/
just repo                       # build both RPMs + the dnf repo into out/repo (needs ../hdots)
just iso-container hafnium      # build an ISO in a Fedora container (podman)
just iso-container hafnium-nvidia
just vm hafnium                 # try it in a UEFI QEMU VM
```

GitHub Actions workflows:

| Workflow | When | Does |
|---|---|---|
| [`check.yml`](.github/workflows/check.yml) | pull requests, pushes to other branches, called by `repo.yml` and by hdots | [`build-scripts/check`](build-scripts/check): builds the RPMs, validates the kickstarts, dry-runs both install transactions against the real Fedora/RPM Fusion/Terra/Dux repos, deploys the default dotfiles in a throwaway `$HOME` and runs `niri validate`, and runs shellcheck plus JSON and Justfile checks |
| [`repo.yml`](.github/workflows/repo.yml) | push to `main`, nightly, manual, or hdots' workflow | Runs `check.yml`, and only if it passes, builds `hafnium` + `hafnium-dots` and deploys the dnf repo to GitHub Pages |
| [`build-iso.yml`](.github/workflows/build-iso.yml) | kickstart changes, weekly, manual | Builds both ISOs and publishes them to the rolling `latest` release |

Packages are versioned `0.1.0-<commits>.git<sha>`, so every push produces an upgrade.
They're unsigned and served over HTTPS from your own Pages site (`gpgcheck=0`).

## Credits

The structure, defaults and ideas come from [Zirconium](https://github.com/zirconium-dev/zirconium)
and [zdots](https://github.com/zirconium-dev/zdots).
