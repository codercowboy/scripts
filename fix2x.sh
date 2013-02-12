#!/bin/bash

########################################################################
#
# fix2x.sh - generate @2x and non-@2x image assets for IOS projects
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2013/02/12
#  - Initial version
#
########################################################################
#
# Copyright (c) 2013 Coder Cowboy, LLC. All rights reserved.
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

if test -z "${1}"
then
	echo "USAGE: fix2x.sh directory"
	echo ""
	echo "fix2x.sh automatically makes @2x and non-@2x images from a directory"	
	echo "files in your directory should end with .png or .jpg"
	exit 1
fi


for FILE in `find ${1} -type f`
do
	echo "Now processing file: ${FILE}"
	# first let's figure out what the @2x file and the non-@2x file should be called
	NORMAL_FILE=$FILE
	TWOX_FILE=$FILE
	# string contains from: http://stackoverflow.com/questions/229551/string-contains-in-bash
	# replace string stuff: http://tldp.org/LDP/abs/html/string-manipulation.html
	if [[ "${FILE}" == *"@2x."* ]] #this is a 2x file
	then	
		NORMAL_FILE=${FILE/%@2x.png/.png}
		NORMAL_FILE=${NORMAL_FILE/%@2x.jpg/.jpg}
		echo "Creating ${NORMAL_FILE}"
		cp ${FILE} ${NORMAL_FILE}
	else #this is not a 2x file
		TWOX_FILE=${FILE/%.png/@2x.png}
		TWOX_FILE=${TWOX_FILE/%.jpg/@2x.jpg}
		echo "CREATING ${TWOX_FILE}"
		cp ${FILE} ${TWOX_FILE}
	fi
	
	WIDTH=`sips -g pixelWidth ${TWOX_FILE} | grep "Width:" | sed 's/.*: //'`
	HEIGHT=`sips -g pixelHeight ${TWOX_FILE} | grep "Height:" | sed 's/.*: //'`	
	echo "Original width: ${WIDTH}, height: ${HEIGHT}"

	NEW_WIDTH=`echo "${WIDTH} / 2" | bc`
	NEW_HEIGHT=`echo "${HEIGHT} / 2" | bc`
	echo "Small width: ${NEW_WIDTH}, height: ${NEW_HEIGHT}"
	# bc examples: http://linux.byexamples.com/archives/42/command-line-calculator-bc/

	# sips examples: http://osxdaily.com/2012/11/25/batch-resize-a-group-of-pictures-from-the-command-line-with-sips/

	sips -z ${NEW_HEIGHT} ${NEW_WIDTH} ${NORMAL_FILE}	
done
#first we're going to make sure we have @2x and non-@2x versions of each file

