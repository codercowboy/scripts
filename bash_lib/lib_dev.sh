#!/bin/bash

if [ "`type -t chrome_local_dev`" = "function" ]; then
	echo "Skipping import functions from lib_dev.sh, they're already sourced in this shell"
	return 0
fi

#####################
# DEVELOPMENT STUFF #
#####################

function chrome_local_dev {
	# from: https://stackoverflow.com/questions/3102819/disable-same-origin-policy-in-chrome
	open /Applications/Google\ Chrome.app --args --user-data-dir="/var/tmp/Chrome dev session" --disable-web-security
}
export -f chrome_local_dev

alias usejdk11='echo "switching to jdk 11" && export JAVA_HOME=${TOOLS}/jdk-11.0.18.jdk/Contents/Home'
alias usejdk8='echo "switching to jdk 8" && export JAVA_HOME=${TOOLS}/jdk1.8.0_411/Contents/Home'
usejdk11

export M2_HOME="${TOOLS}/apache-maven-3.8.6" # maven stuff
export MAVEN_OPTS="-Xmx3g -XX:MaxPermSize=512m" # maven stuff
export MVND_HOME="${TOOLS}/mvnd-0.8.2-darwin-amd64" # mvnd
export GOPATH=${HOME}/Documents/code/tools/go #go

export PATH="${JAVA_HOME}/bin:${M2_HOME}:${M2_HOME}/bin:${MVND_HOME}/bin:${GOPATH}/bin:${PATH}"
export PATH="${PATH}:${TOOLS}/eclipse/Eclipse.app/Contents/MacOS" # eclipse
export PATH="/usr/local/bin:${PATH}" # homebrew stuff is installed here
export PATH="/Applications/RealVNC/VNC\ Viewer.app/Contents/MacOS:${PATH}" # vnc viewer

#start a http server in current directory
alias webserverhere='python -m SimpleHTTPServer 8070'