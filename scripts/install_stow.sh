#!/bin/bash
# Installs the stow package to ~/.local/bin.
# This is useful for installing stow on systems without root access.

mkdir -p ${HOME}/.local/src
cd ${HOME}/.local/src

# Download and extract the stow package
wget http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
tar -xvf stow-latest.tar.gz

release=$(ls -Avr | grep -m1 -axEe 'stow-[0-9.]+')
cd $release

# Configure and build the stow package
./configure --prefix=${HOME}/.local/
make
make install

# Clean up
cd ${HOME}/.local/src
rm -rf stow-latest.tar.gz ${release}*
