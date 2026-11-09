# Building

## How it fits together

- **ISO:** the Fedora netinstall ISO with a [kickstart](../kickstart) embedded by `mkksiso`.
- **Packages:** [`kansora.spec`](../kansora.spec) (files from [`files/`](../files)) plus
  `kansora-dots` from [kdots](https://github.com/euandeas/kdots). Both are published as
  a dnf repo on GitHub Pages: <https://euandeas.github.io/kansora/repo/>.
- **Updates:** installed systems pull new packages from that repo with `dnf upgrade`.

Packages are versioned `0.1.0-<commits>.git<sha>`, so every push is an upgrade.
They're unsigned (`gpgcheck=0`) and served over HTTPS.

## Workflows

| Workflow | Runs on | Does |
|---|---|---|
| [`check.yml`](../.github/workflows/check.yml) | PRs, other branches, kdots pushes | [`build-scripts/check`](../build-scripts/check), see below |
| [`repo.yml`](../.github/workflows/repo.yml) | push to `main`, nightly, manual | runs the checks, then publishes the package repo |
| [`build-iso.yml`](../.github/workflows/build-iso.yml) | kickstart changes, weekly, manual | builds both ISOs into the `latest` release |

`build-scripts/check` has five checks:

- builds the RPMs
- validates the kickstarts
- dry-runs both install transactions against the real repos
- deploys the default dotfiles in a throwaway `$HOME` and runs `niri validate`
- lints the scripts

For kdots changes to publish immediately, add a `KANSORA_DISPATCH_TOKEN` secret to
kdots: a fine-grained token with *Actions: Read and write* on this repo. Otherwise
they go out with the nightly build.

## Locally

| Command | Does |
|---|---|
| `just check` | all checks, in a Fedora container |
| `just ks` | render and validate the kickstarts |
| `just repo` | build the RPMs and repo into `out/repo` |
| `just iso-container <kansora\|kansora-nvidia>` | build an ISO into `out/` |
| `just vm <variant>` | boot an ISO in a UEFI QEMU VM |

`just check` and `just repo` expect kdots checked out at `../kdots`.

## New Fedora release

Installed systems: `kansora upgrade-fedora` checks that Fedora, RPM Fusion, Terra and
both Dux COPRs have the next release, then runs `dnf system-upgrade`. The Kansora
packages are noarch and release-independent, so they carry over as they are.

New ISOs: set `FEDORA_VERSION` in the [Justfile](../Justfile),
[`build-iso`](../build-scripts/build-iso), [`ks-render`](../build-scripts/ks-render)
and the workflows, after checking that the Dux COPRs, Terra and RPM Fusion have builds.
