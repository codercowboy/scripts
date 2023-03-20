#!/bin/bash

########################################################################
#
# fixnefs.sh - fixes mismatched JPEG/NEF/ARW dates created by my renameit.sh
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2020/03/05
#  - Don't rename files when the name is the same.
#  - Don't rename files when target file exists.
#  - Added counters / summary at end of run for sanity checking.
#  - Added support for Sony "ARW" raw format files.
#
# 2017/05/02
#  - Initial version
#
########################################################################
#
# Copyright (c) 2017, Coder Cowboy, LLC. All rights reserved.
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


function print_usage() {
	echo "fixnefs.sh - fix NEF/ARW file names to match JPGs"
	echo
	echo "USAGE"
	echo "  fixnefs.sh PATH"
	echo
	echo "ARGUMENTS"
	echo "  PATH - the path to files to check"
	echo
	echo "NOTES"
	echo "  Only files located directly within the directory specified will be renamed."
	echo
	echo
	echo "  ERROR: $1"
	exit 1
}


if  [ -z "$1" ]; then
	print_usage "Invalid arguments specified."
fi

if [ ! -d "$1" ]; then
	print_usage "$1 is not a directory."
fi

BASE_PATH="${1%*/}/" #this will put a / on the end of the path if there isnt one already

#
# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
# for help w/ dos2unix to TR convert tip
#

#make for's argument seperator newline only
IFS=$'\n'
NL=$'\n'

RAW_FILES=`find "${1}" -maxdepth 1 -type f |  egrep "NEF|ARW|arw|nef" | sort`
RAW_FILES_COUNT_BEFORE=`find "${1}" -maxdepth 1 -type f |  egrep "NEF|ARW|nef|arw" | wc -l`

JPG_FILES="`find "${1}" -maxdepth 1 -type f | grep DSC | grep -v ARW | grep -v NEF | grep -v arw | grep -v nef`"

CHANGED_FILE_COUNTER=0
SKIPPED_FILE_NO_CHANGE_COUNTER=0
SKIPPED_FILE_NO_MATCH_COUNTER=0
SKIPPED_FILE_TOO_MANY_MATCHES_COUNTER=0
SKIPPED_FILE_FILE_EXISTS_COUNTER=0

for RAW_FILE in $RAW_FILES; do
	ORIGINAL_EXTENSION=`basename "${RAW_FILE}" | sed 's/.*\.//'`
	ORIGINAL_BASENAME=`basename "${RAW_FILE}" | sed 's/.*DSC/DSC/' | sed 's/.NEF//' | sed 's/.ARW//' | sed 's/.nef//' | sed 's/.arw//'`
	ORIGINAL_FILEDATE=`basename "${RAW_FILE}" | sed 's/\(.*\) .*/\1/'`	
	echo ""
	echo "Current file: ${RAW_FILE}, originally: ${ORIGINAL_BASENAME}.${ORIGINAL_EXTENSION}, date: ${ORIGINAL_FILEDATE}"	

	MATCHING_JPG_FILES="`echo "${JPG_FILES}" | grep ${ORIGINAL_BASENAME} | grep ${ORIGINAL_FILEDATE}`"
	if [ -z `printf "${MATCHING_JPG_FILES}" | tr -d [[:space:]]` ]; then
		echo "  Found no matches for file ${ORIGINAL_BASENAME} with date ${ORIGINAL_FILEDATE}, trying just file part (${ORIGINAL_BASENAME})"
		MATCHING_JPG_FILES="`echo "${JPG_FILES}" | grep ${ORIGINAL_BASENAME}`"
	fi

	# tr command here removes all whitespace
	MATCHING_JPG_FILE_COUNT="`echo "${MATCHING_JPG_FILES}" | wc -l | tr -d '[[:space:]]'`"
	if [ -z "${MATCHING_JPG_FILES}" ]; then
		MATCHING_JPG_FILE_COUNT="0"
	fi

	# echo "Matching: ${MATCHING_JPG_FILES}"

	if [ "1" = "${MATCHING_JPG_FILE_COUNT}" ]; then
		JPG_BASENAME="`echo "${MATCHING_JPG_FILES}" | sed 's/.JPG//'`"
		TARGET_NAME="${JPG_BASENAME}.${ORIGINAL_EXTENSION}"
		echo "  Found 1 match: ${MATCHING_JPG_FILES}"
		#echo "  Match's basename: ${JPG_BASENAME}, target fixed file: ${TARGET_NAME}"
		if [ -e "${TARGET_NAME}" ]; then
			if [ "${RAW_FILE}" = "${TARGET_NAME}" ]; then
				echo "  NOT FIXING, file name is same: ${TARGET_NAME}"
				((SKIPPED_FILE_NO_CHANGE_COUNTER=SKIPPED_FILE_NO_CHANGE_COUNTER + 1))
			else
				echo "  NOT FIXING, file exists: ${TARGET_NAME}"
				((SKIPPED_FILE_FILE_EXISTS_COUNTER=SKIPPED_FILE_FILE_EXISTS_COUNTER + 1))
			fi			
		else
			echo "  FIXED: ${RAW_FILE} -> ${TARGET_NAME}"
			mv "${RAW_FILE}" "${TARGET_NAME}"	
			((CHANGED_FILE_COUNTER=CHANGED_FILE_COUNTER + 1))
		fi		
	elif [ "0" = "${MATCHING_JPG_FILE_COUNT}" ]; then
		echo "  Skipping, no matches found."
		((SKIPPED_FILE_NO_MATCH_COUNTER=SKIPPED_FILE_NO_MATCH_COUNTER + 1))
	else
		echo "  Skipping, found incorrect number of matches: ${MATCHING_JPG_FILE_COUNT} ${NL} ${MATCHING_JPG_FILES}"
		((SKIPPED_FILE_TOO_MANY_MATCHES_COUNTER=SKIPPED_FILE_TOO_MANY_MATCHES_COUNTER + 1))
	fi		
done

RAW_FILES_COUNT_AFTER=`find "${1}" -maxdepth 1 -type f -name '*' |  egrep "NEF|ARW|arw|nef" | wc -l`

echo ""
echo "Processed ${RAW_FILES_COUNT_BEFORE} RAW files."
echo "  Files Changed: ${CHANGED_FILE_COUNTER}"
echo "  Files Skipped, already named correctly: ${SKIPPED_FILE_NO_CHANGE_COUNTER}"
echo "  Files Skipped, no matches: ${SKIPPED_FILE_NO_MATCH_COUNTER}"
echo "  Files Skipped, too many matches: ${SKIPPED_FILE_TOO_MANY_MATCHES_COUNTER}"
echo "  Files Skipped, file exists: ${SKIPPED_FILE_FILE_EXISTS_COUNTER}"
echo "  Files before starting: ${RAW_FILES_COUNT_BEFORE}"
echo "  Files after renaming: ${RAW_FILES_COUNT_AFTER}"
echo ""
if [ ${RAW_FILES_COUNT_BEFORE} -ne ${RAW_FILES_COUNT_AFTER} ]; then
	echo "WARNING: File count differs after rename operation, were some deleted?"
	exit 1
fi