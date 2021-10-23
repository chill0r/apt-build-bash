#!/bin/bash
#
# Functions for apt-build
#

function check_user {
	local usr=$1
		
	if [[ "$(whoami)" != "$usr" ]]; then
		debug 0 "This function is required to be run as $req"
		debug 1 "Required: $req, current user: $(whoami)"
		return 1
	fi
	return 0
}

function check_access {
	local usr=$1
	local access=$2
	local dir=$3
	
	sudo -u $usr test -$access $dir || return 1
	return 0
}

function debug {
	local level=$1
	local message=$2

	if [[ $verbose -le $level ]]; then
		echo $message
	fi
}


function get_version {
	local src_dir=$1
	ret=$(cat $src_dir/debian/changelog | head -n 1 | cut -d " " -f 2 | cut -d "(" -f 2 | cut -d ")" -f 1)
}

function modify_changelog {
	local src_dir=$1
	#Note: This directly modifies the changelog!
	get_version $src_dir
	local vers=$ret
	if [[ "x$(echo $vers | grep +aptbuild)" != "x" ]]; then
		debug 2 "$src_dir: Already build, increasing version $vers"
		vers=$(echo $vers | sed -re 's/^(.*\+aptbuild)([0-9]+)/echo "\1$((\2+1))"/ge')
	else
		vers="$vers+aptbuild1"
	fi
	debug 1 "Modified version: $vers"
	local prog=$(cat $src_dir/debian/changelog | head -n 1 | cut -d " " -f 1)
	# Write the modified changelog
	echo -e "$prog ($vers) UNRELEASED; urgency=low\n\n  * Build with apt-build\n\n -- apt build <build@$(hostname).local>  $(date -R)\n\n$(cat $src_dir/debian/changelog)" > $src_dir/debian/changelog
}


function get_installed_packages {
	ret="$(dpkg-query -l | tr -s " " | grep -E "^ii" | cut -d " " -f 2)"
}

function get_pkg_dir {
	local pkg=$1
	debug 2 "Searching for $pkg- in $source_cache"	
	ret=$(ls -d $source_cache/* | grep $pkg-)
}


function build_package {
	local pkg_dir=$1
	local repo_dir=$2
	local package=$3
	
	pushd $pkg_dir > /dev/null
	debug 1 "Using source directory $pkg_dir"
	eval $build_command
	popd > /dev/null
	get_version $pkg_dir
	local pkgdeb=$(ls $source_cache | grep $package_$ret | grep .deb)
	debug 2 "Package for $package ($ret): $pkgdeb"
	if [[ "x$pkgdeb" == "x" ]]; then
		echo "Unable to find built package for $package" >&2
		exit 1
	fi
	debug 1 "Moving $pkgdeb to $repo_dir"
	# Simply move all *.deb files
	mv $source_cache/*.deb $repo_dir
}
