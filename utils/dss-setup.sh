#!/bin/sh

# Copyright (c) 2019  Darren Spruell <phatbuckett@gmail.com>
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
# Set system up to use an extracted Didier Stevens Suite.
# See comments below for actions performed.
# https://github.com/DidierStevens/DidierStevensSuite

# The script uses a hardcoded Python virtual environment path.
# If the venv does not exist, it will be created. A few quirks are
# worked around:
#
# - One or more dependency names are updated for the Linux platform.
# - She-bang (interpreter lines) are updated.
# - Python scripts are marked executable.

set -e -u

PATH="/usr/bin"

PY_ENV="/opt/didier-steven-suite/env"

# Provide an extracted ZIP archive directory as an input parameter
TDIR="$1"

if [ ! -d "${PY_ENV}" ]; then
	# Ensure parent directory exists
	mkdir -v -p "$(dirname "${PY_ENV}")"
	# Create virtualenv
	echo "[*] Creating virtualenv..."
	python3 -m venv "${PY_ENV}"
fi

# Fix up dependency name on Linux
if [ "$(uname -s)" = "Linux" ]; then
	echo "[*] Setting dependency name..."
	sed -E -i 's@^(python-magic)-bin@\1@' "${TDIR}/requirements.txt"
fi

# Install dependencies
echo "[*] Installing Python modules..."
"${PY_ENV}/bin/python3" -m pip install -v -r "${TDIR}/requirements.txt"

# Update she-bang lines. Don't assume that /usr/bin/python exists or points
# to Python 3.
echo "[*] Setting virtualenv interpreters..."
sed -i '1s@^#!.*$@#!'${PY_ENV}'/bin/python3@' "${TDIR}"/*.py

# Make scripts executable
echo "[*] Setting executable modes..."
chmod -v +x "${TDIR}"/*.py
