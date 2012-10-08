#!/bin/bash

########################################################################
#
# linecounter.sh - source code line counting script
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
# 2006/10/25
#  - updated usage info
# 2006/9/14
#  - initial version
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

if test -z $1
then
	echo "linecounter.sh is a line counting script"
  	echo
	echo "USAGE:"
	echo "  linecounter.sh PATH"
	echo
	echo "ARGUMENTS:"
	echo "  PATH - the path to find files to count lines for"
  	exit
fi

totallines=0

#make for's argument seperator newline only
IFS=$'\n'

for file in `find "$1" -type f`
do
  	echo -n "$file "

  	#cat echoes the file
  	#the first grep command filters lines without alphanumeric characters
  	# .. which is probably a decent way to determine a line of code
  	# .. it will at least filter whitespace lines, and empty lines with brackets
  	#the second grep command filters lines that start with a * or # or // or /*
  	#the wc command counts the lines (we could also use -c on grep for efficiency..)

	filelines=`cat "$file" | grep -e [[:alnum:]] | grep -v "^[[:space:]]*[\*|#|//|/\*]" | wc -l`
	echo $filelines
	let totallines=$totallines+$filelines
done
echo "Total Lines $totallines"

