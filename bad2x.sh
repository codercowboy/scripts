#!/bin/bash

########################################################################
#
# bad2x.sh - list @2x image files with odd dimensions
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
	echo "USAGE: bad2x.sh directory"
	exit 1
fi

#make for's argument seperator newline only
IFS=$'\n'

echo "The following @2x files have odd dimensions, and will resize by half poorly."

for FILE in `find ${1} -type f | grep "@2x"`
do
	WIDTH=`sips -g pixelWidth "${FILE}" | grep "Width:" | sed 's/.*: //'`
	HEIGHT=`sips -g pixelHeight "${FILE}" | grep "Height:" | sed 's/.*: //'`	
	WIDTH_IS_ODD=`echo "${WIDTH} % 2" | bc`
	HEIGHT_IS_ODD=`echo "${HEIGHT} % 2" | bc`
	if test ${WIDTH_IS_ODD} -eq 1 -o ${HEIGHT_IS_ODD} -eq 1
	then
		echo "${FILE} ${WIDTH}x${HEIGHT}"
	fi	
done



