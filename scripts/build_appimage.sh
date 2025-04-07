#!/bin/bash

set -eo pipefail

# Functions
die() {
	echo "[FATAL] $*"
	exit 1
}

runCmd() {
	if ! "$@"; then
		die "command failed: '$*'"
	fi
}

# Constant variables
if [[ $# -lt 2 ]]; then
	echo "$0: WORKSPACE APPDIR"
	exit 1
fi

WORKSPACE="$1"
APPDIR="$2"
WGET_ARGS=(--continue --no-verbose)
ARCH="$(uname -m)"

# Reset arguments
set --

# Set update information
[[ -n "$VERSION" ]] && export RELEASE="latest" || export RELEASE="continuous"
export LDAI_UPDATE_INFORMATION="gh-releases-zsync|${GITHUB_REPOSITORY//\//|}|${RELEASE}|CPU-X-*$ARCH.AppImage.zsync"
export LDAI_VERBOSE=1
echo "LDAI_UPDATE_INFORMATION=$LDAI_UPDATE_INFORMATION"

# Bundle deps
runCmd cp --verbose "$APPDIR/usr/share/applications/io.github.thetumultuousunicornofdarkness.cpu-x.desktop" "$APPDIR"
runCmd cp --verbose "$APPDIR/usr/share/icons/hicolor/256x256/apps/io.github.thetumultuousunicornofdarkness.cpu-x.png" "$APPDIR"
runCmd mv --verbose "$APPDIR"/usr "$APPDIR"/shared

runCmd wget "${WGET_ARGS[@]}" "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
runCmd chmod --verbose a+x ./lib4bin
runCmd ./lib4bin -p -v -s -k \
	--dst-dir "$APPDIR" \
	"$APPDIR"/shared/bin/cpu-x \
	/usr/lib/"$ARCH"-linux-gnu/libvulkan*.so* \
	/usr/lib/"$ARCH"-linux-gnu/libgirepository-*.so* \
	/usr/lib/"$ARCH"-linux-gnu/gtk-*/*/immodules/*.so \
	/usr/lib/"$ARCH"-linux-gnu/gdk-pixbuf-*/*/loaders/*
runCmd ./lib4bin -s --with-wrappe --dst-dir "$APPDIR"/bin "$APPDIR"/shared/bin/cpu-x-daemon

runCmd mv --verbose "$APPDIR"/shared/glib-*/schemas/* "$APPDIR"/share/glib-*/schemas/*
runCmd ln ./sharun ./AppRun
runCmd ./sharun -g

# Make AppImage
runCmd mkdir --parents --verbose "$WORKSPACE/AppImage" && runCmd cd "$_"
runCmd wget "${WGET_ARGS[@]}" "https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"
runCmd chmod --verbose a+x ./appimagetool-$ARCH.AppImage
./appimagetool-$ARCH.AppImage --no-appstream -u "$LDAI_UPDATE_INFORMATION" "$APPDIR"
