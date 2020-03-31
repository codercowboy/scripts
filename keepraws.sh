#!/bin/bash

########################################################################
#
# keepraws.sh - removes NEF/ARW files in a directory that don't 
#   have similarly named JPG/jpeg files
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2020/03/10
#  - Initial version
#
########################################################################
#
# Copyright (c) 2020, Coder Cowboy, LLC. All rights reserved.
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
	echo "keepraws.sh - remove RAW (NEF/ARW) files that don't have matching JPG/jpegs"
	echo
	echo "USAGE"
	echo "  keepraws.sh PATH"
	echo
	echo "ARGUMENTS"
	echo "  PATH - the path to files to check"
	echo
	echo "NOTES"
	echo "  Only files located directly within the directory specified will be renamed."
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

JPG_FILES="`find "${1}" -maxdepth 1 -type f | grep DSC | egrep "JPG|jpeg"`"
#note, we need to put quotes around "${JPG_FILES}" to make bash print with new lines in the var
#echo "found jpg files: \"${JPG_FILES}\""

RAW_FILES=`find "${1}" -maxdepth 1 -type f | egrep "NEF|ARW" | sort`
RAW_FILE_COUNT_BEFORE=`echo "${RAW_FILES}" | wc -l`

REMOVED_FILE_COUNTER=0
KEPT_FILE_COUNTER=0

REMOVED_DIR="${1}/removed"
if [ ! -e "${REMOVED_DIR}" ]; then
	echo "Creating removed directory: ${REMOVED_DIR}"
	mkdir -p "${REMOVED_DIR}"
fi

#make for's argument seperator newline only
IFS=$'\n'

for RAW_FILE in $RAW_FILES; do
	FILE_BASENAME=`basename "${RAW_FILE}" | sed 's/.NEF//' | sed 's/.ARW//'`
	#echo "Now processing RAW file: ${RAW_FILE}, basename: ${FILE_BASENAME}"

	MATCHING_JPG_FILES="`echo "${JPG_FILES}" | grep ${FILE_BASENAME}`"
	# tr command here removes all whitespace
	MATCHING_JPG_FILE_COUNT="`echo "${MATCHING_JPG_FILES}" | wc -l | tr -d '[[:space:]]'`"
	if [ -z "${MATCHING_JPG_FILES}" ]; then
		MATCHING_JPG_FILE_COUNT="0"
	fi

	#echo "  Matching JPGs: ${MATCHING_JPG_FILES}"
	#echo "  Matching JPG file count: ${MATCHING_JPG_FILE_COUNT}"

	if [ "1" = "${MATCHING_JPG_FILE_COUNT}" ]; then
		echo "Keeping ${RAW_FILE}, jpg exists: ${MATCHING_JPG_FILES}"
		((KEPT_FILE_COUNTER=KEPT_FILE_COUNTER + 1))
	elif [ "0" = "${MATCHING_JPG_FILE_COUNT}" ]; then
		TARGET="${REMOVED_DIR}/${RAW_FILE}"
		echo "Removing ${RAW_FILE}, no jpg exists, moving it to: ${TARGET}"
		mv "${RAW_FILE}" "${TARGET}"
		((REMOVED_FILE_COUNTER=REMOVED_FILE_COUNTER + 1))
	fi
done

FINAL_JPG_FILE_COUNT=`find "${1}" -maxdepth 1 -type f |  egrep "JPG|jpeg" | wc -l | tr -d '[[:space:]]'`
FINAL_RAW_FILE_COUNT=`find "${1}" -maxdepth 1 -type f |  egrep "NEF|ARW" | wc -l | tr -d '[[:space:]]'`

echo ""
echo "Processed ${FILES_COUNT_BEFORE} RAW files."
echo "  Files Removed: ${REMOVED_FILE_COUNTER}"
echo "  Files Kept: ${KEPT_FILE_COUNTER}"
echo "  Final JPG file Count: ${FINAL_JPG_FILE_COUNT}"
echo "  Final RAW file Count: ${FINAL_RAW_FILE_COUNT}"
echo ""
if [ ${FINAL_JPG_FILE_COUNT} -ne ${FINAL_RAW_FILE_COUNT} ]; then
	echo "WARNING: Final JPG file count doesn't match final RAW file count."
	exit 1
fi