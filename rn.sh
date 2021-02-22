#!/bin/bash

########################################################################
#
# rn.sh - file renaming utilities
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2020/12/20
#  - Initial version
#
########################################################################
#
# Copyright (c) 2021, Coder Cowboy, LLC. All rights reserved.
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


function print_usage()
{
	echo "rn.sh - file renaming utilities"
	echo
	echo "USAGE"
	echo "  rn.sh OPERATION ARGUMENT PATH"
	echo
	echo "ARGUMENTS"
	echo "  OPERATION - one of: prefix, suffix"
	echo "  ARGUMENT - the prefix or suffix to add (before file extension)"
	echo "  PATH - the path to files to check"
	echo
	echo "NOTES"
	echo "  Files will be recursively renamed in all subfolders."
	echo
	echo
	echo "  ERROR: $1"
	exit 1
}

OPERATION="${1}"
ARGUMENT="${2}"
FILE_PATH="${3}"

if [ -z "${1}" -o -z "${2}" -o -z "${3}" ]; then
	print_usage "Invalid arguments specified."
elif [ "${OPERATION}" != "prefix" -a "${OPERATION}" != "suffix" ]; then 
	print_usage "Invalid operation specified: ${OPERATION}"
elif [ ! -d "${FILE_PATH}" ]; then
	print_usage "${FILE_PATH} is not a directory."
fi

BASE_PATH="${FILE_PATH%*/}/" #this will put a / on the end of the path if there isnt one already

#
# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
# for help w/ dos2unix to TR convert tip
#

FILES=`find "${FILE_PATH}" -type f -name '*' | sort | tr -d '\15\32'`

#make for's argument seperator newline only
IFS=$'\n'

for FILE in ${FILES}; do
	echo "current file: ${FILE}"

	ORIGINAL_BASENAME=`basename "$FILE"`
	ORIGINAL_DIRNAME=`dirname "${FILE}"`
	# file/ extenstion extraction examples: https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
	FILE_WITHOUT_EXTENSION="${ORIGINAL_BASENAME%%.*}" # example, blah.tar.sh -> blah
	FILE_EXTENSION="${ORIGINAL_BASENAME#*.}" # example blah.tar.gz -> tar.gz

	# echo "name: ${FILE_WITHOUT_EXTENSION}, extension: ${FILE_EXTENSION}"	

	if [ "${OPERATION}" = "prefix" ]; then
		NEW_FILE="${BASE_PATH}${ARGUMENT}${ORIGINAL_BASENAME}"
	elif [ "${OPERATION}" = "suffix" ]; then
		NEW_FILE="${BASE_PATH}${FILE_WITHOUT_EXTENSION}${ARGUMENT}.${FILE_EXTENSION}"
	fi

	if [ -e "${NEW_FILE}" ]; then
		echo "ERROR: target file already exists, not renaming: ${NEW_FILE}"				
	else
		echo "  Renaming File: ${FILE}"
		echo "    to: ${NEW_FILE}"
		echo

		mv "${FILE}" "${ORIGINAL_DIRNAME}/${NEW_FILE}"
	fi
done
