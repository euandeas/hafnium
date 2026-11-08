fedora_version := env("FEDORA_VERSION", "45")
container := "registry.fedoraproject.org/fedora:" + fedora_version

default:
    @just --list

# Render and validate both kickstarts into out/
ks:
    build-scripts/ks-render hafnium out/hafnium.ks
    build-scripts/ks-render hafnium-nvidia out/hafnium-nvidia.ks

# Build an installer ISO on the host (needs lorax and xorriso)
iso variant="hafnium":
    FEDORA_VERSION={{ fedora_version }} build-scripts/build-iso {{ variant }} out

# Build an installer ISO inside a Fedora container (needs podman only)
iso-container variant="hafnium":
    sudo podman run --rm -it --privileged -v "$PWD:/src:Z" -w /src \
        -e FEDORA_VERSION={{ fedora_version }} {{ container }} \
        bash -c 'dnf install -y lorax xorriso pykickstart && build-scripts/build-iso {{ variant }} out'

# Build both ISOs in a container
isos: (iso-container "hafnium") (iso-container "hafnium-nvidia")

# Run the CI checks (build, kickstarts, install dry-run, dotfiles, lint) in a Fedora container
check hdots="../hdots":
    podman run --rm -it -v "$PWD:/hafnium:Z" -v "$(realpath {{ hdots }}):/hdots:Z" -w /hafnium {{ container }} \
        bash -c 'build-scripts/ci-setup && STRICT=1 build-scripts/check /hdots out/check'

# Build the hafnium + hafnium-dots RPMs and dnf repo into out/repo, as CI does
# (expects the hdots repo checked out next to this one)
repo hdots="../hdots":
    podman run --rm -it -v "$PWD:/src:Z" -v "$(realpath {{ hdots }}):/hdots:Z" -w /src {{ container }} \
        bash -c 'dnf install -y git-core make rpm-build systemd-rpm-macros createrepo_c \
            && git config --global --add safe.directory "*" \
            && build-scripts/build-repo /hdots out'

# Boot an ISO in a UEFI VM with a 40G scratch disk (needs qemu + edk2-ovmf)
vm variant="hafnium":
    #!/usr/bin/env bash
    set -euo pipefail
    iso="out/{{ variant }}-{{ fedora_version }}-x86_64.iso"
    disk="out/{{ variant }}-test.qcow2"
    [[ -f "$disk" ]] || qemu-img create -f qcow2 "$disk" 40G
    cp -n /usr/share/edk2/ovmf/OVMF_VARS.fd out/OVMF_VARS.fd || :
    qemu-system-x86_64 -enable-kvm -m 6G -smp 4 -cpu host \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file=out/OVMF_VARS.fd \
        -drive file="$disk",if=virtio \
        -cdrom "$iso" -boot menu=on \
        -device virtio-vga-gl -display gtk,gl=on \
        -nic user,model=virtio-net-pci

clean:
    rm -rf out .build

# Remove the cached upstream netinstall ISO too
clean-all: clean
    rm -rf cache
