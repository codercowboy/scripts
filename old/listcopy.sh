#!/bin/bash

#####################################################################
#
# listcopy.sh - copy files or folders specified in a text file
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
#####################################################################
#
# UPDATES:
#
# 2006/10/25
#  - changed dos2unix usage to tr
#  - updated usage notes
#
# 2006/10/13
#  - initial version
#
#####################################################################
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
########################################################################


exitcode=0

function print_usage()
{
	echo "listcopy.sh copies files or folders specified in a text file"
	echo
	echo "USAGE"
	echo "  listcopy.sh LIST_FILE TARGET_PATH"
	echo
	echo "NOTES"
	echo "  LIST_FILE should contain only one file or folder entry per line."
	echo
	echo "  Lines in LIST_FILE prefixed with a \"#\" will be ignored."
	echo
	echo "EXIT STATUS"
	echo "  0 - success"
	echo "  1 - errors occurred"
	echo
	echo
	echo "  ERROR: $1"
	echo
	exit 1
}


function list_copy()
{
	#
	# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
	# for help w/ dos2unix to TR convert tip
	#
	LIST_ENTRIES=`cat "$1" | tr -d '\15\32'`

	TARGETPATH=${2%*/}/ #make sure the target path has a / on its end

	#make for's argument seperator newline only
 	IFS=$'\n'

 	for ENTRY in $LIST_ENTRIES
	do

		if test -z "$ENTRY"
		then
			#echo "Ignoring Blank Line." #test stuff
			continue
		fi

		#TODO FUTURE: handle case where there is whitespace before comment marker

		if test ${ENTRY:0:1} = "#"
		then
			#echo "Ignoring Comment: $ENTRY" #test stuff
			continue
		fi

		if test -z `echo "$ENTRY" | grep -E  '[^[:blank:]]+'`
		then
			#echo "Ignoring whitespace: $ENTRY" #test stuff
			continue
		fi

		if test -f "$ENTRY"
		then
			echo "Copying file: $ENTRY"
			cp -f "$ENTRY" "$TARGETPATH"
		elif test -d "$ENTRY"
		then
			#make md5 file
			md5tool.sh CREATE "$ENTRY"
			echo "Copying folder: $ENTRY"
			ENTRY=${ENTRY%*/} #make sure the folder does not have a / on its end
			cp -Rf "$ENTRY" "$TARGETPATH"
		else
			echo "File or folder does not exist: $ENTRY"
			exitcode=1
		fi

	done
}

if test -z "$1" -o -z "$2"
then
	print_usage "Invalid number of arguments specified."
fi

if test ! -r "$1"
then
	print_usage "Cannot read file: $1"
fi

if test ! -d "$2"
then
	print_usage "Target path is not a directory: $2"
fi

if test ! -w "$2"
then
	print_usage "Target path is not writable: $2"
fi

list_copy "$1" "$2"

exit $exitcode