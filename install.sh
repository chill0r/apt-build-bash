#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
	echo "Please run this script as root" >&2
	exit 1
fi

# Remove default apt build
apt-get remove apt-build

# Install local-apt-repository
apt-get install local-apt-repository

# Make directories
# Configuration
mkdir -p /etc/apt-build/
# For local-apt-repository
mkdir -p /srv/local-apt-repository/
# Files
mkdir -p /usr/lib/apt-build/
# Cache
mkdir -p /var/cache/apt-build/source


# Copy config
[[ -f "/etc/apt-build/apt-build.conf" ]] || cp apt-build.conf.ex /etc/apt-build/apt-build.conf

# Copy scripts
cp ./*.sh /usr/lib/apt-build/
cp apt-build /usr/lib/apt-build/

# Create symlink in /usr/bin
ln -s /usr/lib/apt-build/apt-build /usr/bin/apt-build
