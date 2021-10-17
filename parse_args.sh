#!/bin/bash
OPTIND=1

# Preset option arguments (DON'T use the config names, prepend with "a" so we can safely load the config later without overwriting)


akeep_build_dependencies=
averbose=0
abuild_command=
arecursive=

# Default values
config=/etc/apt-build/apt-build.conf
source_cache=/var/cache/apt-build/source
pkg_cache=/srv/local-apt-repository
apt_yes=""
force_rebuild=false


function usage {
	echo "$(basename $0) <OPTIONS> [MODE] <PACKAGES>"
	echo "  Options:"
	echo "  -h       Show this help and exit"
	echo "  -k       Keep build dependencies"
	echo "  -v       Verbose (can be used multiple times)"
	echo "  -c FILE  Use FILE as configuration file"
	echo "  -b CMD   Set the build command to CMD"
	echo "  -r       Build the build dependencies"
	echo "  -y       Assume yes for apt-get"
	echo "  -f       Force rebuild of already build packages (only for world mode)"
	echo ""
	echo "$(basename $0) version 0.0.1-alpha"
	return
}

while getopts ":hkvc:b:ryf" arg; do
	case $arg in
		h)
			usage
			exit 0
			;;
		k)
			akeep_build_dependencies=true
			;;
		v)
			averbose=$((verbose+1))
			;;
		c)
			config=$OPTARG
			;;
		b)
			abuild_command=$OPTARG
			;;
		r)
			arecursive=true
			;;
		y)
			apt_yes="-y"
			;;
		f)
			force_rebuild=true
			;;
		
		:)
			usage
			echo "Missing argument for $OPTARG" >&2
			exit 1
			;;
		?)
			usage
			echo "Invalid option $OPTARG" >&2
			exit 1
			;;
		
		*)
	esac
done

shift $((OPTIND-1))
mode=$1
shift 1
packages=$@

if [[ -z $mode ]]; then
	usage
	exit 1
fi

# Load configuration
if [[ ! -f $config ]]; then
	echo "No configuration file found at $config" >&2
	exit 1
fi
. $config

# Overwrite the config values with the ones from the commandline call in case it's set
if [[ "x$akeep_build_dependencies" != "x" ]]; then
	keep_build_dependencies=$akeep_build_dependencies
fi
if [[ "x$averbose" != "x0" ]]; then
	verbose=$averbose
fi
if [[ "x$abuild_command" != "x" ]]; then
	build_command=$abuild_command
fi
if [[ "x$arecursive" != "x" ]]; then
	recursive=$arecursive
fi

if [[ "x$build_command" == "x" ]]; then
	echo "No build command given... Exiting" >&2
	exit 1
fi

if [[ $(id -u) != 0 ]]; then
	echo "This program requires root to run" >&2
	exit 1
fi


# Call depending on mode
case $mode in
	upgrade|dist-upgrade|full-upgrade)
		handler_upgrade
		;;
	install)
		handler_install false $packages
		;;
	remove|uninstall)
		apt-get remove $apt_yes --purge $packages
		;;
	clean)
		rm -rf $source_cache/*
		rm -rf $pkg_cache/*
		;;
	world)
		handler_world
		;;
	*)
		usage
		exit 1
		;;
esac
