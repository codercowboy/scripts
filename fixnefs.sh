#!/bin/bash

########################################################################
#
# fixnefs.sh - fixes mismatched JPEG/NEF dates created by my renameit.sh
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


function print_usage()
{
	echo "fixnefs.sh - fix NEF files to match JPGs"
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


if  test -z "$1"
then
	print_usage "Invalid arguments specified."
fi

if test ! -d "$1"
then
	print_usage "$1 is not a directory."
fi

BASE_PATH="${1%*/}/" #this will put a / on the end of the path if there isnt one already

#
# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
# for help w/ dos2unix to TR convert tip
#

#make for's argument seperator newline only
IFS=$'\n'

FILES=`find "${1}" -maxdepth 1 -type f -name '*' |  grep NEF | grep DSC | sort | tr -d '\15\32'`

NL=$'\n'
JPG_FILES=""
for JPG_FILE in "`find "${1}" -maxdepth 1 -type f -name '*' | grep DSC | grep JPG`"
do
	JPG_BASENAME="`basename ${JPG_FILE}`"
	#echo "Considering: ${JPG_BASENAME}"
	JPG_FILES="${JPG_FILES}${NL}${JPG_BASENAME}"
done

for FILE in $FILES
do	
	ORIGINAL_BASENAME=`basename "${FILE}" | sed 's/.*DSC/DSC/' | sed 's/.NEF//'`
	ORIGINAL_FILEDATE=`basename "${FILE}" | sed 's/ .*//'`	
	#echo "current file: ${FILE}, originally: ${ORIGINAL_BASENAME}, date: ${ORIGINAL_FILEDATE}"	

	MATCHING_FILES="`printf "${JPG_FILES}" | grep ${ORIGINAL_BASENAME} | grep ${ORIGINAL_FILEDATE}`"

	if test -z `printf "${MATCHING_FILES}" | tr -d [[:space:]]`
	then
		echo "Found no matches for file ${ORIGINAL_BASENAME} with date ${ORIGINAL_FILEDATE}, trying just file part (${ORIGINAL_BASENAME})"
		MATCHING_FILES="`printf "${JPG_FILES}" | grep ${ORIGINAL_BASENAME}`"
	fi

	# echo "Matching: ${MATCHING_FILES}"
	# tr command here removes all whitespace
	MATCHING_FILE_COUNT="`printf "${MATCHING_FILES}${NL}" | wc -l |  tr -d '[[:space:]]'`"

	if test -z `printf "${MATCHING_FILES}" | tr -d [[:space:]]`
	then
		MATCHING_FILE_COUNT="0"
	fi

	if test "1" = "${MATCHING_FILE_COUNT}"
	then		
		JPG_BASENAME="`echo "${MATCHING_FILES}" | sed 's/.JPG//'`"
		TARGET_NAME="${1}/${JPG_BASENAME}.NEF"
		echo "Found 1 match: ${MATCHING_FILES}, basename: ${JPG_BASENAME}"
		echo "FIXED: ${FILE} -> ${TARGET_NAME}"
		mv "${FILE}" "${TARGET_NAME}"
	else
		echo "current file: ${FILE}, originally: ${ORIGINAL_BASENAME}"	
		echo "Found incorrect number of matches: ${MATCHING_FILE_COUNT} ${NL} ${MATCHING_FILES}"
	fi
	
done