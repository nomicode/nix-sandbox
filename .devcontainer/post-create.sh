#!/bin/sh -ex

WORKSPACE_DIR="${1:-${PWD}}"

apt_install() {
    DEBIAN_FRONTEND=noninteractive
    export DEBIAN_FRONTEND
    sudo apt-get -q update
    sudo apt-get -q install -y --no-install-recommends xz-utils
    sudo find /var/lib/apt/lists -mindepth 1 -delete
}

apt_install

setup_nix_dir() {
    sudo mkdir -p /nix
    username=$(id -un)
    group=$(id -gn)
    sudo chown -R "${username}:${group}" /nix
}

setup_nix_etc() {
    sudo mkdir -p /etc/nix
    sudo touch /etc/nix/nix.conf
    echo 'sandbox = false' | sudo tee -a /etc/nix/nix.conf
}

install_nix() {
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "${tmp_dir}"' EXIT
    NIX_INSTALL="nix-install.sh"
    cd "${tmp_dir}"
    curl -sL https://nixos.org/nix/install -o "${NIX_INSTALL}"
    chmod 755 "${NIX_INSTALL}"
    "./${NIX_INSTALL}" \
        --no-daemon --nix-extra-conf-file "${WORKSPACE_DIR}/nix.conf"
}

setup_nix_dir
setup_nix_etc
install_nix
