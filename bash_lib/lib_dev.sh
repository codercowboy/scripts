#!/bin/bash

if [ "`type -t chrome_local_dev`" = "function" ]; then
	echo "Skipping import functions from lib_dev.sh, they're already sourced in this shell"
	return 0
fi

#####################
# DEVELOPMENT STUFF #
#####################

export CODE=${HOME}/Documents/code
export TOOLS=${HOME}/Documents/code/tools

alias code='cd "${CODE}"'
alias tools='cd "${TOOLS}"'

function chrome_local_dev {
	# from: https://stackoverflow.com/questions/3102819/disable-same-origin-policy-in-chrome
	open /Applications/Google\ Chrome.app --args --user-data-dir="/var/tmp/Chrome dev session" --disable-web-security
}
export -f chrome_local_dev

export GOPATH=${HOME}/Documents/code/tools/go #go

export PATH="${GOPATH}/bin:${PATH}"
export PATH="/usr/local/bin:${PATH}" # homebrew stuff is installed here
export PATH="/opt/homebrew/bin:${PATH}" # homebrew also here
export PATH="/Applications/RealVNC/VNC\ Viewer.app/Contents/MacOS:${PATH}" # vnc viewer
export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:${PATH}"
export PATH="${HOME}/Documents/code/tools/yt-dlp_macos:${PATH}"
export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:${PATH}" # use xcode git

#start a http server in current directory
alias webserverhere='python -m http.server 8070'

##############
# JAVA STUFF #
##############

alias usejdk24='echo "switching to jdk 24" && export JAVA_HOME=${TOOLS}/jdk/jdk-24.0.2.jdk/Contents/Home'
alias usejdk21='echo "switching to jdk 21" && export JAVA_HOME=${TOOLS}/jdk/jdk-21.0.2.jdk/Contents/Home'
alias usejdk11='echo "switching to jdk 11" && export JAVA_HOME=${TOOLS}/jdk/jdk-11.0.18.jdk/Contents/Home'
alias usejdk8='echo "switching to jdk 8" && export JAVA_HOME=${TOOLS}/jdk/jdk1.8.0_411/Contents/Home'
usejdk21

export PATH="${PATH}:${TOOLS}/eclipse/Eclipse.app/Contents/MacOS" # eclipse
export PATH="${JAVA_HOME}/bin:${PATH}"

alias jvisualvm='${TOOLS}/visualvm/VisualVM.app/Contents/MacOS/visualvm --jdkhome ${JAVA_HOME}'

#############
# K8S STUFF #
#############

function k8s_ssh {
	if [ -z "${KUBE_NS}" -o -z "${KUBE_HOST}" ]; then
		echo "Error: KUBE_NS or KUBE_HOST env var doesn't exist"
		return 1
	fi
	# example: kubectl exec -it -n my-ns my-k8s-host -- /bin/bash
	kubectl exec -it -n ${KUBE_NS} ${KUBE_HOST} -- /bin/bash
}
export -f k8s_ssh

function k8s_cp_to {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "USAGE: k8s_cp_to file [local file] [remote fully qualified path]"
		echo "Exampe local path: some-file.tar.gz"
		echo "Example remote path: /opt/somewhere/some-file.tar.gz"
		return 1
	elif [ -z "${KUBE_NS}" -o -z "${KUBE_HOST}" ]; then
		echo "Error: KUBE_NS or KUBE_HOST env var doesn't exist"
		return 1
	fi
	echo "Copying local '${1}' to remote '${2}'"
	# example: kubectl cp some-file.gz my-ns/my-k8s-host:/opt/somewhere/some-file.tar.gz
	kubectl cp "${1}" "${KUBE_NS}/${KUBE_HOST}:${2}"

	return ${?}
}
export -f k8s_cp_to

function k8s_cp_from {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "USAGE: k8s_cp_from file [remote fully qualified path] [local file]"
		echo "Example remote path: /opt/somewhere/some-file.tar.gz"
		echo "Exampe local path: some-file.tar.gz"
		return 1
	elif [ -z "${KUBE_NS}" -o -z "${KUBE_HOST}" ]; then
		echo "Error: KUBE_NS or KUBE_HOST env var doesn't exist"
		return 1
	fi
	echo "Copying remote '${1}' to local '${2}'"
	# example: kubectl cp my-ns/my-k8s-host:/opt/somewhere/some-file.tar.gz some-file.gz
	kubectl cp "${KUBE_NS}/${KUBE_HOST}:${1}" "${2}"

	return ${?}
}
export -f k8s_cp_from

################
# DOCKER STUFF #
################

function docker_am_i_inside {
	if [ -f /.dockerenv ]; then
		echo "In Docker"
	else
		echo "*NOT IN DOCKER!!*"
	fi
}
export -f docker_am_i_inside

##############
# MISC STUFF #
##############

export EDITOR=vi # fight me.
