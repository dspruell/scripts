#!/bin/sh

# Copyright (c) 2024 Darren Spruell <phatbuckett@gmail.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


# Quickly install one or more YARA releases from source code in a common
# directory root, setting the foundation for testing functionality and
# signature compatibility with multiple versions. (This could be done, for
# example, with the `yara-multiscan.sh` script).
#
# Prerequisites for YARA build/installation should be completed as noted in
# YARA's documentation:
#
# https://yara.readthedocs.io/en/latest/gettingstarted.html
#
# It is also assumed that the directory specified as YARA_ENGINES_ROOT is
# writable by the user executing this script, which is typically expected to be
# a normal (i.e., non-root) user.
#
# This script runs the make(1) command using multiple jobs (using its `-j`
# option). By default, 4 jobs are used to speed up the build. If this value is
# not desired, the value of NUM_MAKE_JOBS (which is also read from an
# environment variable) may be updated. The use of this option has been shown
# to reduce the build time by half or more.
#
# It may be convenient to execute this script using script(1) to capture build
# output in case of issues. To execute the script, specify one or more valid
# release versions as arguments:
#
# script -c "./utils/yara-install.sh 4.0.0 4.0.5 4.1.3 4.2.3 4.3.2 4.4.0 4.5.0"
#
# If a requested version is already installed, a log message will note this
# and the installation of that version will not continue. When downloading
# a source distribution, the file will be cached for any future attempts to
# install the same version.
#
# Sample release URL from YARA GitHub project:
#
# https://github.com/VirusTotal/yara/archive/refs/tags/v4.5.0.tar.gz

set -e

YARA_ENGINES_ROOT="${YARA_ENGINES_ROOT:-/opt/yara}"
YARA_DIST_CACHE_DIR="$YARA_ENGINES_ROOT/cache"

NUM_MAKE_JOBS="${NUM_MAKE_JOBS:-4}"

YARA_DIST_TPL="https://github.com/VirusTotal/yara/archive/refs/tags/v%%VER_NO%%.tar.gz"

# Log informational output
log_info()
{
	_msg="$1"
	echo "[INFO] $_msg"
}

# Log successful output
log_ok()
{
	_msg="$1"
	echo "[OK] $_msg"
}

# Log failure output
log_nok()
{
	_msg="$1"
	echo "[ERR] $_msg"
}

# Check that a specific version of YARA is installed in the setup directory.
check_yara_ver()
{
	VER="$1"
	YPATH="$YARA_ENGINES_ROOT/yara-${VER}/bin/yara"
	if [ -x "$YPATH" ]
	then
		log_ok "YARA v${VER} is installed ($YPATH)"
		return 0
	else
		log_info "YARA v${VER} is not installed ($YPATH)"
		return 1
	fi
}

# Install a version of YARA into its setup directory.
# If a distribution tarball is not present in the setup directory, download and
# cache it for possible future installation attempts.
install_yara_ver()
{
	VER="$1"
	YARA_DIST_FNAME="yara-$VER.tar.gz"
	YARA_DIST_FILE="$YARA_DIST_CACHE_DIR/$YARA_DIST_FNAME"
	YARA_INSTALL_PREFIX_DIR="$YARA_ENGINES_ROOT/${YARA_DIST_FNAME%.tar.gz}"
	if [ ! -f "$YARA_DIST_FILE" ]
	then
		YARA_URL="$(get_dist_url "$VER")"
		download_url_to_directory "$YARA_URL" "$YARA_DIST_CACHE_DIR"
	fi
	cd "$YARA_DIST_CACHE_DIR"
	tar zxf "$YARA_DIST_FNAME"
	cd "${YARA_DIST_FNAME%.tar.gz}"
	./bootstrap.sh
	./configure \
		--prefix="$YARA_INSTALL_PREFIX_DIR" \
		--with-crypto \
		--enable-magic
	make -j"${NUM_MAKE_JOBS}"
	make -j"${NUM_MAKE_JOBS}" install
}

# Construct and return a YARA distribution build URL for the specified version.
get_dist_url()
{
	VER="$1"
	echo "$YARA_DIST_TPL" | sed -e "s/%%VER_NO%%/${VER}/"
}

# Download file from the given URL to the specified directory.
download_url_to_directory()
{
	url="$1"
	dest="$2"
	log_info "Downloading $url to $dest"
	curl --output-dir "$dest" -L -O -J "$url"
}

# Validate that the caller has specified one or more versions to be operated
# on.
if [ "$#" -eq 0 ]
then
	log_nok "Usage: $(basename "$0") <VERSION> [...])"
	exit 1
fi

# Create the cache directory if it doesn't yet exist.
if [ ! -d "$YARA_DIST_CACHE_DIR" ]
then
	log_ok "Creating cache directory ($YARA_DIST_CACHE_DIR)"
	mkdir -p "$YARA_DIST_CACHE_DIR"
fi

for YARA_VERSION in "$@"
do
	if ! check_yara_ver "$YARA_VERSION"
	then
		log_info "Preparing to install YARA v${YARA_VERSION}..."
		install_yara_ver "$YARA_VERSION"
		log_info "Completed setup of YARA v${YARA_VERSION}."
	fi
done
