#!/bin/bash

. "$(dirname "$0")/build_base.sh"
WINE_PREFIX="${WINE_PREFIX:-/usr/local/opt/wine_cx_${CROSS_OVER_VERSION}}"

set -ex

source_prepare

# Configure and build wine x86_64
mkdir -p "${BUILDROOT}/wine64"
pushd "${BUILDROOT}/wine64"
[ -e Makefile ] || "${WINE_CONFIGURE}" "--prefix=${WINE_PREFIX}" "${WINE_CONFIG[@]}" --enable-win64 CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"
make -j${NPROC}
popd

# Configure and build wine x32
mkdir -p "${BUILDROOT}/wine32"
pushd "${BUILDROOT}/wine32"
[ -e Makefile ] || "${WINE_CONFIGURE}" "--prefix=${WINE_PREFIX}" "${WINE_CONFIG[@]}" --with-wine64=../wine64 CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"
make -j${NPROC}
popd

# Install wine
make -C "${BUILDROOT}/wine64" install-lib
make -C "${BUILDROOT}/wine32" install-lib
for winecommands in winepath winemine winefile winedbg wineconsole winecfg wineboot regsvr32 regedit notepad msiexec msidb; do
    cp -uv "${WINE_APPLOADER}" "${WINE_PREFIX}/bin/$winecommands"
done

# Tar Wine
chmod -R u+rw,g+r,o+r "${WINE_PREFIX}"
tar -czvf ${WINE_INSTALLATION}.tar.gz "${WINE_PREFIX}"
