#!/bin/sh

function handler_install {
	# Handles building and installations
	local is_dep=$1
	shift 1
	local todo=$@

	if [[ "x$todo" == "x" ]]; then
		return
	fi
	

	

	# Deepest level of dependencies or building the real packages now
	for x in $todo; do
		# Check if the package is in the ignored packages list
		local skip=false
		for i in $ignored_packages; do
			if [[ "x$(echo $x | grep -E $i)" != "x" ]]; then
				skip=true
				break
			fi
		done
		if [[ $skip == true ]]; then
			debug 0 "Package $x marked as ignored. Skipping"
			continue
		fi
		echo "[ ----- Getting dependencies for $todo -----]"
		get_build_dependencies $todo || exit 1
		local deps=$ret
		if [[ $recursive == true ]]; then
			# Recursive call of dependency building requested
			handler_install true $deps
		else
			install_package true $deps || exit 1
		fi
		get_source_package $x
		local src_pkg=$ret
		echo "[ ----- Downloading source for $x ----- ]"
		download_source $source_cache $src_pkg || exit 1
		get_pkg_dir $src_pkg
		debug 1 "Package directory for $x: $ret"
		local pkgdir=$ret
		modify_changelog $pkgdir || exit 1
		echo "[ ----- Building $x ----- ]"
		build_package $pkgdir $pkg_cache $src_pkg
		get_version $pkgdir
		local vers=$ret
		# Remove the dependencies
		apt-get $apt_yes --purge remove $deps
		# Wait a bit for local-apt-repository to find / index our file
		sleep 2
		apt-get update # Update to get our new version
		echo "[ ----- Installing $x:$vers -----]"
		# Note: If a removed build dependency is a runtime dependency too it'll be installed
		# again so I don't need to care about that
		install_package $is_dep "$x=$vers" || exit 1 # Install exactly our version
	done
	
}

function handler_upgrade {
	# Handles the upgrade process
	
	# Get the pending upgrades
	get_upgrades_pending
	echo "[ ----- Available upgrades ----- ]"
	echo $ret
	echo ""
	# Pass the upgrades to the install handler
	handler_install $ret
	
}

function handler_world {
	# First do the upgrades
	handler_upgrade
	
	# Get a list of all installed packages
	get_installed_packages
	local pkgs=$ret
	local todo=""
	if [[ $force_rebuild != true ]]; then
		# Remove the packages which are already build
		for x in $pkgs; do
			debug 2 "Checking if package $x is already build"
			if [[ "x$(apt-cache madison $x | head -n 1 | tr -s ' ' | cut -d ' ' -f 4 | grep -E '\+aptbuild[0-9]+')" == "x" ]]; then
				debug 1 "Building the world: Package $x"
				# ToDo: Add the commandline arguments again
				apt-build install $x
			fi
		done
	else
		debug 0 "Rebuilding of already build packages requested, skipped package build check"
		apt-build install $pkgs
	fi
	
}