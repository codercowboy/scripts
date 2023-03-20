#!/bin/bash

########################################################################
#
# bash_profile.sh - my personal bash profile
#
#   NOTE: to include this file's contents in your environment, you'll
#         need to install it by adding 'source bash_profile.sh' to the
#         '.bash_profile' file in your home directory.
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2021/05/04
#  - Add various my_rsync functions
#  - Add various file zip/tar functions
#  - Add various OSX functions
#  - Add local_chrome_dev and clean_dot_files
#
# 2017/05/10
#  - Add function to clear out local time machine backups
#
# 2017/05/02
#  - Initial version
#
########################################################################
#
# Copyright (c) 2012, Coder Cowboy, LLC. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied.
#
########################################################################

export CODE=${HOME}/Documents/code
export TOOLS=${HOME}/Documents/code/tools

alias code='cd ${CODE}'
alias tools='cd ${TOOLS}'

#################
# SSH SHORTCUTS #
#################

# local port 2121 point to screen share on server
# local port 5901 is proxy for internet thru server
alias ssh_my_server='ssh -L 2121:localhost:5900 -D 5901 ${MY_USER}@${MY_SERVER}'

# open osx's screenshare via terminal
alias screenshare_my_server_ssh='open vnc://localhost:2121'
alias screenshare_my_server_local='open vnc://${MY_SERVER_NAME}._rfb._tcp.local'

###############
# RSYNC STUFF #
###############

# export these functions so child processes, such as scripts running, can see them
# https://stackoverflow.com/questions/33921371/command-not-found-when-running-defined-function-in-script-file

# rsync arguments 
#  -v = verbose
#  -r = recursive 
#  -t = preserve times
#  -W = transfer whole file 
#  --del = delete non existing files
#  -stats = print stats at end
#  --progress = show progress while transfering
#  --chmod = change perms on target
#  -c = skip based on checksum rather than mod-time/size 
#  --size-only = skip only based on size changes, not checksum or modtime
#  --modify-window = allow a mod time drive of N seconds, useful for fat32 with less precise mod-time storage
#  -i = show the reason rsync is transfering the file
#  -n = dry run (test mode)

# itemized changes output example:
# >f..t.... file.txt
# c = checksum differs, s = size differs, t = mod time differs ,p = perms differ
# o = owner differs, g = group differs

function my_rsync_checksum() { 	
	rsync -cvrthW --del --stats --progress --chmod=u=rwx "${@}" 
}
export -f my_rsync_checksum

function my_rsync_checksum_test() { 	
	rsync -incvrthW --del --stats --progress --chmod=u=rwx "${@}" 
}
export -f my_rsync_checksum_test

function my_rsync() { 	
	rsync -vrthW --del --stats --progress --chmod=u=rwx "${@}" 
	echo ""
	echo "WARNING: my_rsync only skips files based on size / mod time differences!"
	echo "  for a more secure checksum-based transfer, use my_rsync_checksum"
}
export -f my_rsync

function my_rsync_test() {	
	rsync -invrthW --del --stats --progress --chmod=u=rwx "${@}" 
	echo ""
	echo "WARNING: my_rsync only skips files based on size / mod time differences!"
	echo "  for a more secure checksum-based transfer, use my_rsync_checksum"
}
export -f my_rsync_test

# fat32's modtime isn't as precise as other file systems, and there are various other problems
# such as the fat32 not storing timezones, so during DST the file's mod time looks to be off by one hour
# for this reason, on the fat32 alias we're using the --size-only command that ignores mod times
# source: https://stackoverflow.com/questions/15640570/rsync-and-backup-and-changing-timezone
# source: https://serverfault.com/questions/470046/rsync-from-linux-host-to-fat32
# fat32's 

function my_rsync_fat32() {	
	rsync -rv --size-only --del --stats --progress "${@}" 
	echo ""
	echo "WARNING: my_rsync_fat32 only skips files based on size difference, not mod time!"
	echo "WARNING: my_rsync_fat32 does not preserve mod-times!"
}
export -f my_rsync_fat32

function my_rsync_fat32_test() {
	rsync -inrv --size-only --del --stats --progress "${@}" 
	echo ""
	echo "WARNING: my_rsync_fat32 only skips files based on size difference, not mod time!"
	echo "WARNING: my_rsync_fat32 does not preserve mod-times!"
}
export -f my_rsync_fat32_test

##############
# MISC STUFF #
##############

# from: http://www.linuxproblem.org/art_9.html
function ssh_setup_passwordless() { 
    if [ "${1}" = "" ]; then
        echo "USAGE: ssh_setup_passwordless user@host"
        return
    fi

    echo "Setting up passwordless ssh on ${1}"

	# create the key
    if [ ! -e ~/.ssh/id_rsa ]; then
        echo "generating rsa key: ~/.ssh/id_rsa"
        ssh-keygen -t rsa -q -N "" -f ~/.ssh/id_rsa
    else
        echo "rsa key for ssh already exists: ~/.ssh/id_rsa"
    fi

	HOST_PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

	REMOTE_COMMAND="mkdir -p ~/.ssh;
		chmod 700 ~/.ssh; 
		echo \"${HOST_PUBLIC_KEY}\" >> ~/.ssh/authorized_keys;
		chmod 644 ~/.ssh/authorized_keys;"

	echo "Enter your password for the remote host, we need this to copy your public key to the remote host with ssh."

	ssh "${1}" "$REMOTE_COMMAND"

	echo "Passwordless setup is complete. You should now be able to verify the passwordless login with: ssh ${1}"
}
export -f ssh_setup_passwordless

function inspect_files {
	if [ "${1}" = "" -o "${2}" = "" ]; then
        echo "USAGE: inspect_files [path] [output file prefix]"
        return
    fi
	echo "Gathering checksum info to file: ${2}-checksums.txt"
	md5tool.sh DISPLAY "${1}" > "${2}-checksums.txt"	
	# reverses output, instead of "2G ./somefile" it is now "./somefile [2G]"
	SED_COMMAND="sed -E 's/^[^[:digit:]]*//' | sed -E 's/[[:space:]]/::/' | sed -E 's/(.*)::(.*)/\2 [\1]/'"
	echo "Gathering dir info to file: ${2}-dirs.txt"
	eval "du -h \"${1}\" | ${SED_COMMAND}" > "${2}-dirs.txt"
	echo "Gathering file info w/ actual size to file: ${2}-files-real-size.txt"
	eval "du -a \"${1}\" | ${SED_COMMAND}" > "${2}-files-real-size.txt"
	echo "Gathering file info w/ summary size to file: ${2}-files-summary.txt"
	eval "du -a -h \"${1}\" | ${SED_COMMAND}" > "${2}-files-summary.txt"
}
export -f inspect_files

alias yt_dlp_mp3='yt-dlp -x --audio-format mp3 --audio-quality 0 ${1}'

######################
# VARIOUS OSX TRICKS #
######################

# handy secret trick to emulate a command+k terminal clear which clears scrollback buffer
alias cls='printf "\33c\e[3J"'

# unlock osx "locked files" (whatever that is)
alias unlock_files='sudo chflags nouchg ${1}/*'

# auto open sublime text to the given directory or file.
# can't get this to work as an alias, oh well.
function stext() { /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl "${@}"; } 
export -f stext

# from: https://stackoverflow.com/a/7177891
# opens a new tab in terminal
function terminal_open_tab() {
    osascript -e 'tell application "Terminal" to activate' \
        -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down'
}
export -f terminal_open_tab

function terminal_tab_execute() {
    COMMAND="${1}"        
    COMMAND="tell application \"Terminal\" to do script \"${1}\" in selected tab of the front window"
    # echo "Command is: \"${COMMAND}\""
    osascript -e 'tell application "Terminal" to activate'
    osascript -e "${COMMAND}"
}
export -f terminal_tab_execute

function thin_local_snapshots() {
	echo "Looking for local time machine backups to remove."
	REMOVAL_COUNT=0
	for SNAPSHOT in `tmutil listlocalsnapshots /`; do
		SNAPSHOT_DATE=`echo "${SNAPSHOT}" | sed 's/com.apple.TimeMachine.//'`
		echo "Removing snapshot '${SNAPSHOT}', date: ${SNAPSHOT_DATE}"
		tmutil deletelocalsnapshots ${SNAPSHOT_DATE}
		REMOVAL_COUNT=$((REMOVAL_COUNT+1))
	done
	echo "Finished removing time machine backups, removed ${REMOVAL_COUNT} backups."
}
export -f thin_local_snapshots

function clean_dot_files {
	if [ -z "${1}" ]; then
		echo "USAGE: clean_dot_files [directory]"
		return;
	fi
	echo "Removing ._* files"
	find "${1}" -type f -name "._*" -exec rm -rv {} \;
	echo "Removing .DS_Store files"
	find "${1}" -type f -name ".DS_Store" -exec rm -rv {} \;
}
export -f clean_dot_files

#####################
# TAR/ZIP FUNCTIONS #
#####################

# arg 1 = command to run ie "zip -r"
# arg 2 = description ie "Zipping"
# arg 3 = file extension for file ie "zip" or "tar"
# arg 4 = path to process files in
function process_each_file() {
	if [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
		echo "USAGE: process_each_file [COMMAND] [DESCRIPTION] [ARCHIVE FILE EXTENSION] [DIRECTORY]"
		echo "\tThis will archive each file (or directory) in the given directory."
		return
	fi
	OLD_IFS=${IFS}
	IFS=$'\n'
	OLD_CWD=`pwd -P`
	cd "${4}"
	FILES=`find . -maxdepth 1 | sort`
	for FILE in ${FILES}; do
		if [ "." = "${FILE}" -o ".." = "${FILE}" ]; then
			continue
		fi
		ORIGINAL_BASENAME=`basename "${FILE}"`
		NEW_FILE="${ORIGINAL_BASENAME}.${3}"
		echo "${2} ${FILE} to ${NEW_FILE}"
		CMD="${1} \"${NEW_FILE}\" \"${FILE}\""
		echo "Executing: ${CMD}"
		eval "${CMD}"
	done
	IFS=${OLD_IFS}
	cd "${OLD_CWD}"
}
export -f process_each_file

function zip_each() {
	if [ -z "${1}" ]; then
		echo "USAGE: zip_each [DIRECTORY]"
		echo "  This will zip each file (or directory) in the given directory."
		return
	fi
	process_each_file "zip -r" "Zipping" "zip" "${1}"
}
export -f zip_each

function tar_each() {
	if [ -z "${1}" ]; then
		echo "USAGE: tar_each [DIRECTORY]"
		echo "  This will tar (without gzip) each file (or directory) in the given directory."
		return
	fi
	process_each_file "tar cvf" "Tarring" "tar" "${1}"
}
export -f tar_each

function targz_each() {
	if [ -z "${1}" ]; then
		echo "USAGE: targz_each [DIRECTORY]"
		echo "  This will tar (with gzip) each file (or directory) in the given directory."
		return
	fi
	process_each_file "tar cvfz" "Tarring" "tar.gz" "${1}"
}
export -f targz_each

function untar_each() {
	if [ -z "${1}" ]; then
		echo "USAGE: untar_each [DIRECTORY]"
		echo "  This will untar each tar in the given directory."
		return
	fi
	cd "${1}" && find . -iname \*.tar\* -exec tar -xvf {} \;
	cd -
}

export -f targz_each

function 7z_each() {
	if [ -z "${1}" ]; then
		echo "USAGE: 7z_each [DIRECTORY]"
		echo "  This will 7zip (with lzma2) each file (or directory) in the given directory."
		return
	fi

	# example: 7z a -r -t7z -m0=lzma2 -mx=9 -mfb=273 -md=1g -ms=10g -mmt=off -mmtf=off -mqs=on -bt -bb3 archife_file_name.7z /path/to/files
	# argument explanations from https://stackoverflow.com/a/52771612
	#   a - add files to archive
	#   -r - Recurse subdirectories
	#   -t7z - Set type of archive (7z in your case)
	#   -m0=lzma2 - Set compression method to LZMA2
	#   -mx=9 - Sets level of compression. x=9 - Ultra
	#   -mfb=273 - Sets number of fast bytes for LZMA. 
	#   -md=4g - Sets Dictionary size for LZMA
	#   -ms=8g - Enables solid mode w/ 8g block size - might decrease compression ratio
	#   -mqs=on - Sort files by type in solid archives. To store identical files together.
	#   -mmt=off - Sets multithreading mode to OFF. 
	#   -mmtf=off - Set multithreading mode for filters to OFF.
	#   -myx=9 - Sets level of file analysis to maximum, analysis of all files (Delta and executable filters).
	#   -bt - show execution time statistics
	#   -bb3 - set output log level 

	#CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mx=9 -mfb=273 -md=1g -ms=4g -mmt=off -mmtf=off -mqs=on -bt -bb3"
	#CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mfb=273 -md=1g -ms=2g -mqs=on -bt -bb3"
	CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mmt=off -mmtf=off -mqs=on -bt -bb3"
	process_each_file "${CMD_PREFIX}" "7Zipping" "7z" "${1}"
}
export -f 7z_each

# ffmpeg stuff

function ffmpeg_convert_webm_to_mp3() {
	if [ -z "${1}" ]; then
		echo "USAGE: ffmpeg_convert_webm_to_mp3 [DIRECTORY]"
		echo "  This will convert each webm in the given directory to mp3."
		return
	fi
	OLD_IFS=${IFS}
	IFS=$'\n'
	FILES=`find ${1} -type f | grep webm`
	for FILE in ${FILES}; do
	    echo -e "Processing video: ${FILE}";	    
	    ffmpeg -i "${FILE}" -codec:a libmp3lame -b:a 320k -ar 44100 -y "${1}/${FILE%.webm}.mp3";
	done;
	IFS=${OLD_IFS}
}
export -f ffmpeg_convert_webm_to_mp3

# youtube-dl stuff

# youtube-dl -f bestaudio --restrict-filenames --max-downloads 999 -r 5000K --buffer-size 16K --audio-quality 0 --sleep-interval 60 --max-sleep-interval 300 "https://www.youtube.com/playlist?list=PLVNmxQCckyw5bo9u008T5cZNJ_QwWW5o1"

#####################
# DEVELOPMENT STUFF #
#####################

function chrome_local_dev {
	# from: https://stackoverflow.com/questions/3102819/disable-same-origin-policy-in-chrome
	open /Applications/Google\ Chrome.app --args --user-data-dir="/var/tmp/Chrome dev session" --disable-web-security
}
export -f chrome_local_dev

alias usejdk11='echo "switching to jdk 11" && export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.16.jdk/Contents/Home'
alias usejdk8='echo "switching to jdk 8" && export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_291.jdk/Contents/Home'

usejdk11

export SCRIPTS_HOME="`dirname ${BASH_SOURCE[0]}`"

export M2_HOME="${TOOLS}/apache-maven-3.8.6" # maven stuff
export MAVEN_OPTS="-Xmx3g -XX:MaxPermSize=512m" # maven stuff
export MVND_HOME="${TOOLS}/mvnd-0.8.2-darwin-amd64" # mvnd
export GOPATH=${HOME}/Documents/code/tools/go #go


export PATH="${JAVA_HOME}/bin:${M2_HOME}:${M2_HOME}/bin:${MVND_HOME}/bin:${GOPATH}/bin:${PATH}"
export PATH="${PATH}:${TOOLS}/eclipse/Eclipse.app/Contents/MacOS" # eclipse
export PATH="/usr/local/bin:${SCRIPTS_HOME}:${PATH}" # homebrew stuff is installed here
export PATH="/Applications/RealVNC/VNC\ Viewer.app/Contents/MacOS:${PATH}" #vnc viewer

# make git log output human readable
alias gitlog='git log --pretty=format:"%h - %an, %ar : %s"'

#start a http server in current directory
alias webserverhere='python -m SimpleHTTPServer 8070'

export EDITOR=vi # fight me.

###############
# OLD GARBAGE #
###############

#export PATH=${HOME}/.yarn/bin:${PATH} # yarn for angular2 dev

########
#
# Old IOS Symbolicate junk from this: http://stackoverflow.com/questions/11682789/trying-to-get-symbols-for-an-ios-crash-file
#export PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources/:${PATH}
# do this: sudo /usr/bin/xcode-select -switch /Applications/Xcode.app/Contents/Developer/
# then set this..
#
########