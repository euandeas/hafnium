# Building

## How it fits together

- **ISO:** a live image built with kiwi from [`live/kansora.kiwi`](../live/kansora.kiwi),
  the way Fedora builds its live spins. It boots into niri as `liveuser`
  ([`livesys-niri`](../files-live/usr/libexec/livesys/sessions.d/livesys-niri), from the
  `kansora-live` package) and installs with Anaconda's live installer, which copies the
  image to disk. NVIDIA users run nouveau until `kansora enable-nvidia`.
- **Packages:** [`kansora.spec`](../kansora.spec) (files from [`files/`](../files)) plus
  `kansora-dots` from [kdots](https://github.com/euandeas/kdots). Both are published as
  a dnf repo on GitHub Pages: <https://euandeas.github.io/kansora/repo/>.
- **Identity:** [`kansora-release-identity`](../identity/kansora-release-identity.spec)
  owns `/usr/lib/os-release`, in place of Fedora's `fedora-release-identity-basic`, so
  the system says Kansora while `ID=fedora` stays. `fedora-release-common` requires an
  identity of its exact version-release, so `build-repo` builds it per Fedora release
  from that release's own os-release, and the nightly build picks up Fedora's updates.
- **Per-release repos:** `repo/<N>/` holds the same packages plus the identity for
  Fedora N, and `kansora.repo` points at `repo/$releasever/`. `repo/` itself is the
  current release (`FEDORA_VERSION`), for the installer and older `kansora.repo` files.
  The next release gets a `repo/<N+1>/` as soon as Fedora's repos have it.
- **Updates:** installed systems pull new packages from those repos with `dnf upgrade`.

Packages are versioned `0.2.0-<commits>.git<sha>`, so every push is an upgrade.
They're unsigned (`gpgcheck=0`) and served over HTTPS.

## Workflows

| Workflow | Runs on | Does |
|---|---|---|
| [`check.yml`](../.github/workflows/check.yml) | PRs, other branches, kdots pushes | [`build-scripts/check`](../build-scripts/check), see below |
| [`repo.yml`](../.github/workflows/repo.yml) | push to `main`, nightly (04:00), manual | runs the checks, then publishes the package repo |
| [`build-live.yml`](../.github/workflows/build-live.yml) | `live/` changes, nightly (05:00), manual | builds the live ISO into the `latest` release (fails if over 2 GiB) |

`build-scripts/check` has four checks:

- builds the RPMs, including `kansora-release-identity` for each release
- dry-runs the live image's install transaction, and the same plus `kansora-nvidia`,
  against the real repos (package set and exclusions come from `live/kansora.kiwi`),
  and checks that the identity matches Fedora's current `fedora-release-common`
- deploys the default dotfiles in a throwaway `$HOME` and runs `niri validate`
- lints the scripts and configs

For kdots changes to publish immediately, add a `KANSORA_DISPATCH_TOKEN` secret to
kdots: a fine-grained token with *Actions: Read and write* on this repo. Otherwise
they go out with the nightly build.

## Locally

| Command | Does |
|---|---|
| `just check` | all checks, in a Fedora container |
| `just repo` | build the RPMs and repo into `out/repo` |
| `just live-container` | build the live ISO into `out/` |
| `just vm` | boot the live ISO in a UEFI QEMU VM |

`just check` and `just repo` expect kdots checked out at `../kdots`.

## New Fedora release

Installed systems: `kansora upgrade-fedora` checks that Fedora, RPM Fusion, Terra,
both Dux COPRs and Kansora's own `repo/<N+1>/` have the next release, then runs
`dnf system-upgrade`. The Kansora packages are noarch and carry over as they are;
`kansora-release-identity` is swapped for the one built for the new release.

New ISOs: set `FEDORA_VERSION` in the [Justfile](../Justfile),
[`build-live`](../build-scripts/build-live), the workflows, and the release version in
[`live/kansora.kiwi`](../live/kansora.kiwi), after checking that the Dux COPRs, Terra
and RPM Fusion have builds.
