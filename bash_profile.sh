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
# 2024/07/19
#  - add lib_git.sh
#  - move various helper functions to libs such as lib_security.sh
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

export MY_SCRIPTS_HOME="`dirname ${BASH_SOURCE[0]}`"
export PATH="${MY_SCRIPTS_HOME}:${PATH}"

export CODE=${HOME}/Documents/code
export TOOLS=${HOME}/Documents/code/tools

alias code='cd ${CODE}'

###################################
# Import Various Helper Functions #
###################################

source "${MY_SCRIPTS_HOME}/bash_lib/lib_dev.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_files.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_git.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_macos.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_media.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_rsync.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_security.sh"
source "${MY_SCRIPTS_HOME}/bash_lib/lib_zip_helpers.sh"

##############
# MISC STUFF #
##############

export EDITOR=vi # fight me.