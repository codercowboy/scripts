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

export CODE=/Users/${MY_USER}/Documents/code
export TOOLS=/Users/${MY_USER}/Documents/tools

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

######################
# RANDOM ONE LINERS  #
######################

function my_rsync() { 
	rsync -vrthW --del --stats --progress --chmod=u=rwx "${@}" 
}

function my_rsync_test() {
	rsync -n -aii --delete "$@" | grep -v "\.f " | grep -v "\.d " | grep -v "f\.\." | grep -v '\.d\.\.' | sed 's/.f\+* /newfile /'
}

# from: http://www.linuxproblem.org/art_9.html
function ssh_setup_passwordless() { 
	# create the key
	ssh-keygen -t dsa -q -N "" -f ~/.ssh/id_dsa

	HOST_PUBLIC_KEY=`cat ~/.ssh/id_dsa.pub`

	REMOTE_COMMAND="mkdir -p ~/.ssh; 
		echo \"${HOST_PUBLIC_KEY}\" >> ~/.ssh/authorized_keys;
		chmod 644 ~/.ssh/authorized_keys;"

	echo "Enter your password for the remote host, we need this to copy your public key to the remote host with ssh."

	ssh "${MY_USER}@${MY_SERVER}" "$REMOTE_COMMAND"

	# another interesting shorthand version ..
	#cat ~/.ssh/id_rsa.pub | ssh ${1} 'cat >> .ssh/authorized_keys'
}

######################
# VARIOUS OSX TRICKS #
######################

# handy secret trick to emulate a command+k terminal clear which clears scrollback buffer
alias cls='printf "\33c\e[3J"'

# unlock osx "locked files" (whatever that is)
alias unlock_files='sudo chflags nouchg ${1}/*'

# auto open sublime text to the given directory or file.
# can't get this to work as an alias, oh well.
function stext() { /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ${@}; } 

# from: https://stackoverflow.com/a/7177891
# opens a new tab in terminal
function terminal_open_tab() {
    osascript -e 'tell application "Terminal" to activate' \
        -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down'
}

function terminal_tab_execute() {
    COMMAND="${1}"        
    COMMAND="tell application \"Terminal\" to do script \"${1}\" in selected tab of the front window"
    # echo "Command is: \"${COMMAND}\""
    osascript -e 'tell application "Terminal" to activate'
    osascript -e "${COMMAND}"
}

#####################
# DEVELOPMENT STUFF #
#####################

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home # java stuff
export M2_HOME=/Users/${MY_USER}/Documents/tools/apache-maven-3.0.5 # maven stuff
export MAVEN_OPTS="-Xmx3g -XX:MaxPermSize=512m" # maven stuff
export PATH=${JAVA_HOME}/bin:${PATH}:${M2_HOME}:${M2_HOME}/bin
export PATH=${HOME}/.yarn/bin:${PATH} # yarn for angular2 dev
export PATH=/usr/local/bin:${CODE}/scripts:${PATH}

# make git log output human readable
alias gitlog='git log --pretty=format:"%h - %an, %ar : %s"'

export EDITOR=vi # fight me.

###############
# OLD GARBAGE #
###############

########
#
# Old IOS Symbolicate junk from this: http://stackoverflow.com/questions/11682789/trying-to-get-symbols-for-an-ios-crash-file
#export PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources/:${PATH}
# do this: sudo /usr/bin/xcode-select -switch /Applications/Xcode.app/Contents/Developer/
# then set this..
#
########