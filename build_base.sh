WORKSPACE="$(realpath "$(dirname "$0")")"
NPROC="${NPROC:-$(nproc)}"

CROSS_OVER_VERSION=24.0.7
CROSS_OVER_SOURCE_URL="https://media.codeweavers.com/pub/crossover/source/crossover-sources-${CROSS_OVER_VERSION}.tar.gz"
CROSS_OVER_LOCAL_FILE="crossover-sources-${CROSS_OVER_VERSION}"

BUILDROOT="${WORKSPACE}/build"
WINE_INSTALLATION="wine-cx-${CROSS_OVER_VERSION}"

WINE_CONFIGURE="${WORKSPACE}/sources/wine/configure"
WINE_DISTVERSION="${WORKSPACE}/sources/wine/programs/winedbg/distversion.h"
WINE_APPLOADER="${WORKSPACE}/sources/wine/tools/wineapploader.in"
WINE_CONFIG=('--enable-archs=i386,x86_64'
    '--with-vulkan'
    '--without-alsa'
    '--without-capi'
    '--with-coreaudio'
    '--with-cups'
    '--without-dbus'
    '--without-fontconfig'
    '--with-freetype'
    '--with-gettext'
    '--without-gettextpo'
    '--without-gphoto'
    '--with-gnutls'
    '--without-gssapi'
    '--with-gstreamer'
    '--without-inotify'
    '--without-krb5'
    '--with-mingw'
    '--without-netapi'
    '--with-opencl'
    '--with-opengl'
    '--without-oss'
    '--with-pcap'
    '--with-pcsclite'
    '--with-pthread'
    '--without-pulse'
    '--without-sane'
    '--with-sdl'
    '--without-udev'
    '--with-unwind'
    '--without-usb'
    '--without-v4l2'
    '--without-wayland'
    '--without-x'
    '--disable-winemenubuilder'
    '--disable-win16'
    '--disable-tests')

export PATH=/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/libtool/libexec/gnubin:$PATH

export CC=clang
export CXX=clang++
export CPATH='/usr/local/include'
export LIBRARY_PATH='/usr/local/lib'
export CPPFLAGS='-I/usr/local/opt/libpcap/include'
export CFLAGS='-O3 -Wno-deprecated-declarations'
export CROSSCFLAGS='-O3'
export LDFLAGS='-Wl,-rpath,/usr/local/lib -L/usr/local/opt/libpcap/lib'

function source_prepare() {
    if [ ! -d sources ]; then
        # Downloading Crossover Sources
        [ -e "${CROSS_OVER_LOCAL_FILE}.tar.gz" ] || curl -o "${CROSS_OVER_LOCAL_FILE}.tar.gz" "${CROSS_OVER_SOURCE_URL}"

        # Extract Crossover Sources
        tar xf "${CROSS_OVER_LOCAL_FILE}.tar.gz"
    fi

    [ -e "${WINE_DISTVERSION}" ] || cat <<EOF > "${WINE_DISTVERSION}"
/* ---------------------------------------------------------------
 *   distversion.c
 *
 * Copyright 2013, CodeWeavers, Inc.
 *
 * Information from DISTVERSION which needs to find
 * its way into the wine tree.
 * --------------------------------------------------------------- */

#define WINDEBUG_WHAT_HAPPENED_MESSAGE "This can be caused by a problem in the program or a deficiency in Wine."

#define WINDEBUG_USER_SUGGESTION_MESSAGE "Check the log for any missing native dependencies and install using winetricks"
EOF
}
