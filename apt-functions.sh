
# 
# Functions calling out for apt
# 


function get_build_dependencies {
	#
	# Gets and returns the required packages for building $packages
	#
	# :param $@: Packages to be build
	# returns ret: Packages
	#
	# Requires user: any
	#
	local packages=$@
	ret=$(apt-get -qq -s build-dep $packages | grep "^Inst" | cut -d " " -f 2)
}

function download_source {
	#
	# Downloads the sources for the requested packages
	#
	# :param $1: source directory
	# :param $2+: Requested packages
	#
	# Returns: Nothing
	# 
	# Required user: Write Access to $src_dir (preferred: _apt)
	#
	local src_dir=$1
	shift 1
	local packages=$@
	check_access $(whoami) "w" $src_dir || exit 1
	pushd $src_dir
	apt-get $apt_yes source $packages || exit 1
	popd
}

function get_upgrades_pending {
	#
	# Returns all packages with pending upgrades
	#
	# Returns ret: Packages
	#
	# Required user: any
	#
	ret=$(apt-get -qq -s dist-upgrade | grep ^Inst | grep -v "\+aptbuild\d+" | cut -d " " -f 2)
}

function get_source_package {
	#
	# Returns the name of the source package for a given Package name
	#
	# :param $1: Package namae
	#
	# Returns ret: Source package name
	#
	# Required user: any
	#
	local package=$1
	ret=$(apt-cache showsrc $package | grep "Package: " | cut -d " " -f 2)
}

function install_package {
	#
	# Installs one or more packages
	#
	# :param $1: Should the package(s) be marked as dependency? (true / false)
	# :param $2+: Package names
	#
	# Returns: Nothing
	#
	# Required user: root
	#
	local is_dep=$1
	shift 1
	local packages=$@
	check_user "root" || exit 1
	
	if [[ $is_dep == true ]]; then
		apt-get $apt_yes --mark-auto install $packages
	else
		apt-get $apt_yes install $packages
	fi
}
