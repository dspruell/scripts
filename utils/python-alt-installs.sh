#!/bin/sh
#
# Build and install alternate versions of Python.
#
# This script assumes the following:
#
# - You have a main "system" installation of Python, typically from the OS
#   package manager.
# - You wish to have one or more other versions of Python installed, each able
#   to be run by calling them with their associated version number. These
#   builds will be installed as "alt" installs, able to coexist on the system
#   alongside the main version.
# - You have completed the required preliminary setup for building Python from
#   source from e.g.
#   <https://devguide.python.org/getting-started/setup-building/>.
# - You have a few dependencies installed, including curl(1) and gpg(1).
# - You have selected a path on the filesystem to use for Python alt installs,
#   for example /opt/python-alt.
# - You can use sudo(8) to install builds into the specified path.
# - You have the Python signing key(s) stored in a GnuPG keystore called
#   `trustedkeys.kbx` in the current directory. Signer keys are linked from
#   <https://www.python.org/downloads/>.
#
# The latest Python source distribution versions can be found here:
#
#   <https://www.python.org/downloads/source/>
#
# To invoke this script, call it from a directory where you want Python source
# distributions to be downloaded and built from. Pass the desired alt install
# path and desired version numbers as arguments to the script, as in this
# example:
#
#   python-alt-installs.sh /opt/python-alt 3.8.16 3.9.16 3.11.3
#
#
# Copyright (c) 2023 Darren Spruell <phatbuckett@gmail.com>
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

set -eu

PATH="/usr/local/bin:/usr/bin:/bin"
WORK_DIR="$PWD"

ALT_INSTALL_PATH="$1"
shift 1

for ver in "$@"
do
	echo "[*] Processing version ${ver}"

	# Download source tarball and verification signature
	curl -O "https://www.python.org/ftp/python/${ver}/Python-${ver}.tgz"
	curl -O "https://www.python.org/ftp/python/${ver}/Python-${ver}.tgz.asc"

	# Verify source archives
	gpgv --quiet --keyring ./trustedkeys.kbx \
		"Python-${ver}.tgz.asc" \
		"Python-${ver}.tgz"

	# Extract source archives, build and install
	tar zxf "Python-${ver}.tgz"
	cd "Python-${ver}"
	./configure --prefix "$ALT_INSTALL_PATH" --enable-optimizations
	make -j 4
	sudo make -j 4 altinstall

	# Return to parent directory for any next version build
	cd "$WORK_DIR"
done


