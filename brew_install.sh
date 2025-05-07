#!/bin/bash

HOMEBREW_CORE_PATH="/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core"

function install_brew() {
    wget -c https://github.com/Homebrew/brew/releases/download/4.1.21/Homebrew-4.1.21.pkg
    pkgutil --expand-full Homebrew-4.1.21.pkg brew_install
    sudo brew_install/Homebrew.pkg/Scripts/preinstall
    sudo brew_install/Homebrew.pkg/Scripts/postinstall brew_install brew_install/Homebrew.pkg/Payload

    #brew search coreutils
    brew install ca-certificates
    cp "$(find /usr/local/Cellar/ca-certificates -name cacert.pem)" /usr/local/etc/ca-certificates/cacert_latest.pem

    # Installing dependencies libraries and build tools
    # openssl@3.1.4 works on Mojave
    git -C "${HOMEBREW_CORE_PATH}" checkout ae9fadf07a09eabd60d71e47feef25804a2ff39c
}

function patch_brew() {
    pushd "${HOMEBREW_CORE_PATH}"
    patch -p1 "$(dirname "$0")/brew_mojave.patch"
    popd
}

function brew_install() {
    brew reinstall ca-certificates
    brew install coreutils pkgconfig bison cmake meson mingw-w64 python3 ninja \
        freetype gettext gnutls sdl2 libpcap \
        spirv-headers spirv-tools vulkan-headers vulkan-loader

    # workaround for sphinx-doc
    brew install python@3.12
    python3.12 -m pip install --break-system-packages \
        Babel==2.13.0 \
        numpydoc==1.6.0 \
        requests==2.31.0 \
        urllib3==2.0.7

    # workaround for clang build error
    brew install gcc
    brew install jpeg-xl snappy --cc=gcc-13

    brew install gstreamer
}

set -ex

which brew >/dev/null || install_brew
grep -q 'cacert_latest' "${HOMEBREW_CORE_PATH}/Formula/c/ca-certificates.rb" || patch_brew
brew_install
