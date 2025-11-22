#!/usr/bin/env bash
# Installs the stow package to ~/.local/bin.
# This is useful for installing stow on systems without root access.

mkdir -p "${HOME}"/.local/src
cd "${HOME}"/.local/src || exit

# Download and extract the stow package
wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
tar -xvf stow-latest.tar.gz

release=$(find . -maxdepth 1 -type d -name 'stow-[0-9.]*' | sort -V | tail -n 1)
cd "$release" || exit

# Configure and build the stow package
./configure --prefix="${HOME}"/.local/
make
make install

# Clean up
cd "${HOME}"/.local/src || exit
rm -rf stow-latest.tar.gz "${release}"*