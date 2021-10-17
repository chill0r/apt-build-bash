# apt-build-bash
 apt-build written wit pure bash scripts

# Requirements
 - bash
 - apt-get / apt-source
 - dpkg-buildpackage
 - local-apt-repository (or any other package which provides a local repository)

# Install
Simply execute the install.sh script or execute the commands in it by hand

# Configuration
The config file is in /etc/apt-build/apt-build.conf
This file is sourced in parse_args.sh so you can use it to provide flags
for dpkg-buildpackage too if you want

# Commandline arguments
-h       Show this help and exit  
-k       Keep build dependencies  
-v       Verbose (can be used multiple times)  
-c FILE  Use FILE as configuration file  
-b CMD   Set the build command to CMD  
-r       Build the build dependencies  
-y       Assume yes for apt-get  
-f       Force rebuild of already build packages (only for world mode)  

# Modes
install:  Download, build and install packages  
upgrade / full-upgrade / dist-upgrade:  Download, build and install upgradable packages  
remove / uninstall: Uninstall packages (simply apt-get remove $@)  
clean:  Clean the source and repository folders  
world:  Build all installed packages which are not build yet  

# Bugs
Quoting the man page of the debian apt-build package  
"Many"

You can help improve this scripts by creating a github issue when finding a bug
