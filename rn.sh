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
# 2024/08/01
#  - add 'trim' mode
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
	echo "  rn.sh OPERATION ARGUMENT(S) PATH"
	echo
	echo "EXAMPLE USAGES"
	echo "  rn.sh prefix \"my prefix\" ."
	echo "        ^ adds 'my prefix' to the front of each file name"
	echo "  rn.sh suffix final ."
	echo "        ^ adds 'final' to the end of each file name"
	echo "  rn.sh trim 10 ."
	echo "        ^ trims each filename to be the first ten characters"
	echo "  rn.sh fromfile filenames.txt mp3 ."
	echo "        ^ renames each mp3 file in the directory according to the lines in filenames.txt"
	echo "  rn.sh remove \"some string\" ."
	echo "        ^ removes 'some string' from each file name"
	echo
	echo "ARGUMENTS"
	echo "  OPERATION - one of: prefix, suffix, trim, fromfile"
	echo "  ARGUMENTS"
	echo "    'prefix' mode: the prefix to add to the filename"
	echo "    'suffix' mode: the suffix to add to the filename (before file extension)"
	echo "    'fromfile' mode: "
	echo "       first arg: the file to read filenames from"
	echo "       second (optional) arg: file extension to consider for renaming"
	echo "  PATH - the path to files to check"
	echo
	echo "NOTES"
	echo "  suffix/prefix mode: Files will be recursively renamed in all subfolders."
	echo
	echo "  fromfile mode: Files will be renamed in order of alphabetical sorting of original filenames"
	echo
	echo
	echo "  ERROR: $1"
	exit 1
}

if [ -z "${1}" -o -z "${2}" -o -z "${3}" ]; then
	print_usage "Invalid arguments specified."
fi

OPERATION="${1}"
ARGUMENT="${2}"
FILE_PATH="${3}"
BASE_PATH="${FILE_PATH%*/}" #this will put a / on the end of the path if there isnt one already

#
# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
# for help w/ dos2unix to TR convert tip
#

function run_prefix_or_suffix {
	#make for's argument seperator newline only
	IFS=$'\n'

	if [ ! -d "${FILE_PATH}" ]; then
		print_usage "${FILE_PATH} is not a directory."
	fi

	local FILES=`find "${FILE_PATH}" -type f -name '*' | sort | tr -d '\15\32'`
	for FILE in ${FILES}; do
		# echo "current file: ${FILE}"

		local ORIGINAL_BASENAME=`basename "$FILE"`
		local ORIGINAL_DIRNAME=`dirname "${FILE}"`
		# file/ extenstion extraction examples: https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
		local FILE_WITHOUT_EXTENSION="${ORIGINAL_BASENAME%%.*}" # example, blah.tar.sh -> blah
		local FILE_EXTENSION="${ORIGINAL_BASENAME#*.}" # example blah.tar.gz -> tar.gz

		# echo "name: ${FILE_WITHOUT_EXTENSION}, extension: ${FILE_EXTENSION}"	

		if [ "${OPERATION}" = "prefix" ]; then
			local NEW_FILE="${BASE_PATH}/${ARGUMENT}${ORIGINAL_BASENAME}"
		elif [ "${OPERATION}" = "suffix" ]; then
			local NEW_FILE="${BASE_PATH}/${FILE_WITHOUT_EXTENSION}${ARGUMENT}.${FILE_EXTENSION}"
		fi

		if [ -e "${NEW_FILE}" ]; then
			echo "ERROR: target file already exists, not renaming: ${NEW_FILE}"				
		else
			echo "  Renaming File: ${FILE}"
			echo "             to: ${NEW_FILE}"
			echo

			mv "${FILE}" "${ORIGINAL_DIRNAME}/${NEW_FILE}"
		fi
	done
}

NEW_FILE_NAMES=()

# arg 1 is file to read file names from
function get_filenames {
	local FILE_NAMES_FILE="${1}"
	echo "Reading file names from: ${FILE_NAMES_FILE}"
	if [ ! -e "${FILE_NAMES_FILE}" ]; then
		echo "File does not exist: ${FILE_NAMES_FILE}"
		exit 0
	fi	
	local LINES=`cat "${FILE_NAMES_FILE}"`
	
	#make for's argument seperator newline only
	IFS=$'\n'
	for LINE in ${LINES}; do
		# remove \r char at end of line if it's there
		LINE=`echo "${LINE}" | sed -e 's/\r$//g'`
		# Remove the spaces from the line front
		LINE=`echo "${LINE}" | sed -e 's/^[[:blank:]]*//g'`
		# remove spaces from end of line
		LINE=`echo "${LINE}" | sed -e 's/[[:blank:]]*$//g'`

		# echo "Processing line: '${LINE}'"

		local FIRST_LINE_CHAR=`echo "${LINE}" | head -c 1`
				
		if [ "${LINE}" = "" ]; then
			# echo "Line is empty, skipping: ${LINE}"
			continue
		elif [ "${FIRST_LINE_CHAR}" = "#" ]; then
			# echo "Line starts with '#', skipping: ${LINE}"
			continue
		elif [ "${FIRST_LINE_CHAR}" = "." ]; then
			# echo "Line starts with '.', skipping: ${LINE}"
			continue
		fi

		# echo "Parsed filename '${LINE}'"
		NEW_FILE_NAMES+=( $LINE )
	done	
}

function run_from_file {
	#make for's argument seperator newline only
	IFS=$'\n'

	local FILE_EXTENSION_FILTER=""
	if [ ! -z "${4}" ]; then 
		local FILE_EXTENSION_FILTER="${3}"
		echo "Files with the following extension will be renamed: ${FILE_EXTENSION_FILTER}"
		local FILE_PATH="${4}"
		local BASE_PATH="${FILE_PATH%*/}" #this will put a / on the end of the path if there isnt one already
	else 
		echo "File extension matching is disabled."
	fi

	if [ ! -d "${FILE_PATH}" ]; then
		print_usage "${FILE_PATH} is not a directory."
	else
		echo "Processing files in path: ${FILE_PATH}"
	fi	

	local FILE_NAMES_FILE="${ARGUMENT}"
	get_filenames "${FILE_NAMES_FILE}"
	# echo "got names:"
	# declare -p NEW_FILE_NAMES # prints array details
	local NEW_FILE_NAMES_COUNT=${#NEW_FILE_NAMES[@]}
	local NEW_FILE_NAMES_INDEX=0

	if [ "0" = "${NEW_FILE_NAMES_COUNT}" ]; then
		echo "No file names were found in file. Exiting."
		exit 1
	fi

	local FILE_LIST_FILE_BASENAME=`basename "${FILE_NAMES_FILE}"`

	local FILES=`find "${FILE_PATH}" -type f -d 1 | sort`

	for FILE in ${FILES}; do
		local OLD_BASENAME=`basename "${FILE}"`
		local OLD_FILE_EXTENSION=${OLD_BASENAME##*.}

		echo "Current file: '${OLD_BASENAME}'"

		if [ "${FILE_LIST_FILE_BASENAME}" = "${OLD_BASENAME}" ]; then
			echo "File is named same as list file, skipping: '${OLD_BASENAME}'"
			continue
		elif [ ! -z "${FILE_EXTENSION_FILTER}" -a "${FILE_EXTENSION_FILTER}" != "${OLD_FILE_EXTENSION}" ]; then
			echo "File's extension does not match '${FILE_EXTENSION_FILTER}': '${OLD_BASENAME}', skipping." 
			continue
		fi

		local NEW_FILE_NAME="${NEW_FILE_NAMES[$NEW_FILE_NAMES_INDEX]}.${OLD_FILE_EXTENSION}"

		local ORIGINAL_DIRNAME=`dirname "${FILE}"`
		local NEW_FILE="${ORIGINAL_DIRNAME}/${NEW_FILE_NAME}"

		if [ -e "${NEW_FILE}" ]; then
			echo "ERROR: target file already exists, not renaming: ${NEW_FILE}"				
		else
			echo "  Renaming File: '${FILE}'"
			echo "             to: '${NEW_FILE}'"
			echo

			mv "${FILE}" "${NEW_FILE}"
		fi

		NEW_FILE_NAMES_INDEX=$((NEW_FILE_NAMES_INDEX+1))
		if [ "${NEW_FILE_NAMES_INDEX}" = "${NEW_FILE_NAMES_COUNT}" ]; then
			echo "No further file names exist, quitting"
			break
		fi
	done
}

function run_trim {
	#make for's argument seperator newline only
	IFS=$'\n'

	if [ ! -d "${FILE_PATH}" ]; then
		print_usage "${FILE_PATH} is not a directory."
	fi

	# test to make sure character-count argument makes sense (is an integer)
	echo "testing argument" | head -c "${ARGUMENT}" 2>/dev/null
	if [ ! "0" = "${?}" ]; then
		echo "Invalid trim character count: ${ARGUMENT}"
		exit 1
	fi

	local FILES=`find "${FILE_PATH}" -type f -name '*' | sort | tr -d '\15\32'`
	for FILE in ${FILES}; do
		# echo "current file: ${FILE}"

		local ORIGINAL_BASENAME=`basename "$FILE"`
		local ORIGINAL_DIRNAME=`dirname "${FILE}"`
		# file/ extenstion extraction examples: https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
		local FILE_WITHOUT_EXTENSION="${ORIGINAL_BASENAME%%.*}" # example, blah.tar.sh -> blah
		local FILE_EXTENSION="${ORIGINAL_BASENAME#*.}" # example blah.tar.gz -> tar.gz

		# echo "name: ${FILE_WITHOUT_EXTENSION}, extension: ${FILE_EXTENSION}"	

		local TRIMMED_FILE_WITHOUT_EXTENSION=`echo "${FILE_WITHOUT_EXTENSION}" | head -c ${ARGUMENT}`
		local NEW_FILE="${BASE_PATH}/${TRIMMED_FILE_WITHOUT_EXTENSION}.${FILE_EXTENSION}"

		if [ "${TRIMMED_FILE_WITHOUT_EXTENSION}" = "${FILE_WITHOUT_EXTENSION}" ]; then
			echo "File's name is less than ${ARGUMENT} characters already: ${NEW_FILE}"
		elif [ -e "${NEW_FILE}" ]; then
			echo "ERROR: target file already exists, not renaming: ${NEW_FILE}"				
		else
			echo "  Renaming File: ${FILE}"
			echo "             to: ${NEW_FILE}"
			echo

			mv "${FILE}" "${ORIGINAL_DIRNAME}/${NEW_FILE}"
		fi
	done
}

# arg 1 = string to remove from filenames
function run_remove {
	#make for's argument seperator newline only
	IFS=$'\n'

	local SEARCH_STRING="${1}"

	local FILES=`find "${FILE_PATH}" -type f -name '*' | sort | tr -d '\15\32'`
	for FILE in ${FILES}; do
		# echo "current file: ${FILE}"

		local ORIGINAL_BASENAME=`basename "$FILE"`
		local ORIGINAL_DIRNAME=`dirname "${FILE}"`

		# string replace: https://stackoverflow.com/questions/13210880/replace-one-substring-for-another-string-in-shell-script
		local NEW_BASE_NAME="${ORIGINAL_BASENAME//$SEARCH_STRING/}"

		local NEW_FILE="${BASE_PATH}/${NEW_BASE_NAME}"

		if [ "${ORIGINAL_BASENAME}" = "${NEW_BASE_NAME}" ]; then
			echo "File doesn't contain: '${SEARCH_STRING}': ${NEW_FILE}"
		elif [ -e "${NEW_FILE}" ]; then
			echo "ERROR: target file already exists, not renaming: ${NEW_FILE}"				
		else			
			echo "  Renaming File: ${FILE}"
			echo "             to: ${NEW_FILE}"
			echo

			mv "${FILE}" "${ORIGINAL_DIRNAME}/${NEW_FILE}"
		fi
	done
}

if [ "${OPERATION}" = "prefix" -o "${OPERATION}" = "suffix" ]; then
	run_prefix_or_suffix
elif [ "${OPERATION}" = "trim" ]; then
	run_trim
elif [ "${OPERATION}" = "fromfile" ]; then
	run_from_file $@
elif [ "${OPERATION}" = "remove" ]; then
	run_remove "${2}"
else 
	echo "Unsupported mode: ${OPERATION}"
	exit 1
fi

exit 0


