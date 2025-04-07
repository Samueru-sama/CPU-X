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

# Run linuxdeploy
echo "LDAI_UPDATE_INFORMATION=$LDAI_UPDATE_INFORMATION"

runCmd cp --verbose "$APPDIR/usr/share/applications/io.github.thetumultuousunicornofdarkness.cpu-x.desktop" "$APPDIR"
runCmd mv --verbose "$APPDIR"/usr "$APPDIR"/shared

runCmd wget "${WGET_ARGS[@]}" "https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
runCmd chmod --verbose a+x ./lib4bin
runCmd ./lib4bin -p -v -s -k "$APPDIR"/shared/bin/* -d "$APPDIR"
runCmd mkdir --parents --verbose "$WORKSPACE/AppImage" && runCmd cd "$_"
runCmd wget "${WGET_ARGS[@]}" "https://github.com/pkgforge-dev/appimagetool-uruntime/releases/download/continuous/appimagetool-$ARCH.AppImage"
./appimagetool --no-appstream -u "$UPINFO" "$APPDIR"
