#
# Configuration for apt-build
#

# Build command
build_command="dpkg-buildpackage -i -uc -us -b"

# Source cache directory
source_cache=/var/cache/apt-build/source

# Package repository
pkg_cache=/srv/local-apt-repository

# Ignored packages (checked with grep -E)
ignored_packages=""

# You can set CFLAGS and so on here. This file will be sourced by apt-build
# so your environment variables will be set too
#
# export CFLAGS="-O3 -fstack-protector-strong -mtune=native -march=native"
# export DEB_CFLAGS_APPEND=$CFLAGS
# export DEB_CXXFLAGS_APPEND=$CFLAGS
# export DEB_CCFLAGS_APPEND=$CFLAGS
# export DEB_CPPFLAGS_APPEND=$CFLAGS
