#!/bin/bash

########################################################################
#
# splitfiles.sh - split and join files and directories
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2021/6/14
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

#arg 1 is error
function print_usage() {
	echo "USAGE: splitfiles.sh [operation] [arguments] [file or directory]"
	echo ""
	echo "OPERATIONS:"
	echo "  split [part size] - split specified file or directory into specified size"
	echo "  join - join specified file or all split files in specified directory"
	echo ""
	echo "NOTE ON SPLIT PART SIZE ARGUMENT:"
	echo ""
	echo "  Part size for 'split' operation can be a raw number such as '1234581'," 
	echo "  or 'k' / 'm' can be specified such as '500m' for 500 megabyte part size"
	echo ""
	echo "EXAMPLE USAGE:"
	echo ""
	echo "  # example: split file.txt into 500 megabyte chunks"
	echo "  splitfile.sh split 500m file.txt"
	echo ""
	echo "  # example: split each file in my_dir directory into 500 megabyte chunks"
	echo "  splitfile.sh split 500m my_dir"
	echo ""
	echo "  # example: join file.txt"
	echo "  splitfile.sh join file.txt"
	echo ""
	echo "  # example: join previously-split files in my_dir directory"
	echo "  splitfile.sh join my_dir"
	echo ""
	echo "ERROR: ${1}"
	exit 1
}

#arg 1 = size, ie 2m for two megabytes
#arg 2 = file
function split_file() {
	# -b is byte count, first arg is file to split, second arg is prefix of split files
	if [ -e "${2}.part.aa" ]; then
		echo "Not splitting file, it has already been split: ${2}"
		return
	fi
	echo -n "Splitting file: ${2} into ${1} parts ... "
	if [ -s "${2}" ]; then
		# if file is not-zero sized, do the split
		split -b ${1} "${2}" "${2}.part."
	else
		#echo "WARNING: file is zero-sized: ${2}" 
		# if file is zero-sized, just copy it to ".part.aa" for consistency
		cp "${2}" "${2}.part.aa"
	fi
	#asterisk reference: https://unix.stackexchange.com/questions/378205/use-asterisk-in-variables
	local PARTS_LIST=( "${2}.part."* )
	echo "(${#PARTS_LIST[@]} parts created)"
	#echo "Parts: ${PARTS_LIST[@]}"
}

#arg 1 = original file name
#arg 2 = output file name
function join_file() {		
	if [ ! -e "${1}.part.aa" ]; then
		echo "Could not find parts to join for file: ${1}"
		return
	elif [ -e "${2}" ]; then
		echo "Not joining file, output file already exists: ${2}"
		return
	fi
	local PARTS_LIST=( "${1}.part."* )
	#echo "Parts: ${PARTS_LIST[@]}"
	echo -n "Joining file: ${1} (${#PARTS_LIST[@]} parts) ... "
	cat "${PARTS_LIST[@]}" > "${2}"
	echo " Finished"
}

# arg 1 = directory to search
# arg 2 = suffix to add to original filename (ie "joined" )
function join_files() {
	local SUFFIX=".${2}"
	if [ "." = "${SUFFIX}" ]; then
		SUFFIX=""
	fi
	echo "Joining Files From Directory: ${1}"
	local FILE_LIST=( "${1}/"*.part.aa )	
	# echo "Found files to join: ${FILE_LIST[@]}"
	for FILE in "${FILE_LIST[@]}"; do
		local ORIGINAL_FILE=`echo "${FILE}" | sed 's/.part.aa//'`
		join_file "${ORIGINAL_FILE}" "${ORIGINAL_FILE}${SUFFIX}"
	done
	echo "Finished Joining Files."
}

# arg 1 = file
function get_checksum() {
	md5sum "${1}"| sed 's/ .*//'
}

# arg 1 is directory to run test in
function run_test() {
	echo "starting test"
	local TMP_DIR="${1}/${RANDOM}"
	
	echo "TMP_DIR: ${TMP_DIR}"
	
	# create our test directory
	mkdir -p "${TMP_DIR}"

	local SMALL_FILE="${TMP_DIR}/small file.bin"
	echo "creating 1MB small file: ${SMALL_FILE}"
	local MEGABYTE=`expr 1024 \* 1024`
	head -c ${MEGABYTE} /dev/random > "${SMALL_FILE}"
	
	local BIG_FILE="${TMP_DIR}/big file.bin"
	echo "creating 100MB big file: ${BIG_FILE}"	
	local HUNDRED_MEGABYTE=`expr 100 \* ${MEGABYTE}`
	head -c ${HUNDRED_MEGABYTE} /dev/random > "${BIG_FILE}"

	echo "splitting small file into 2MB chunks (it will make one file that's the same as the original file)"
	# -b is byte count, first arg is file to split, second arg is prefix of split files
	split_file 2m "${SMALL_FILE}"

	echo "splitting large file into 2MB chunks"
	split_file 2m "${BIG_FILE}"

	echo "putting large file back together (into ${BIG_FILE}.joined)"
	join_file "${BIG_FILE}" "${BIG_FILE}.joined"

	join_files "${TMP_DIR}" "joined2"

	echo "File list:"
	ls -alh "${TMP_DIR}"
	echo ""

	local ALL_FILES_LIST=( "${TMP_DIR}/"* )
	echo ""
	echo "ALL_FILES_LIST: ${ALL_FILES_LIST[@]}"
	echo ""
	echo "Checksums:"
	md5sum "${ALL_FILES_LIST[@]}"
	echo ""

	local TEST_SUCCESS="true"

	local BIG_FILE_CHECKSUM=`get_checksum "${BIG_FILE}"`
	local BIG_FILE_JOINED_CHECKSUM=`get_checksum "${BIG_FILE}.joined"`
	echo "BIG_FILE_CHECKSUM: ${BIG_FILE_CHECKSUM}"
	echo "BIG_FILE_JOINED_CHECKSUM: ${BIG_FILE_JOINED_CHECKSUM}"

	
	if [ "${BIG_FILE_CHECKSUM}" != "${BIG_FILE_JOINED_CHECKSUM}" ]; then
		echo "TEST FAILED: Big file checksums do not match."
		local TEST_SUCCESS="false"
		
	fi

	if [ "${TEST_SUCCESS}" = "true" ]; then
		echo "TEST RESULT: SUCCESS"
	else
		echo "TEST RESULT: FAILED"
	fi
		
	echo "finished test, cleaning up"
	if [ ! -z "${TMP_DIR}" ]; then
		rm -rf "${TMP_DIR}"
	fi
}

# run_test "."

if [ "split" = "${1}" ]; then
	if [ "${#}" != "3" ]; then
		print_usage "Invalid arguments specified. ('split' mode arguments: splitfiles.sh split [part size] [file or directory])"
	elif [ ! -e "${3}" ]; then
		print_usage "Specified file or directory doesn't exist: ${3}"
	fi

	# the first sed here strips a trailing 'm' or 'k' off the part size, which is a valid suffix
	# the second sed her strips all consecutive digits out, which now should leave an empty string if it was digits followed by 'm', 'k', or nothing
	PART_SIZE_CHECK=`echo "${2}" | sed 's/[mk]$//' | sed 's/[0-9]*//'`
	if [ ! -z "${PART_SIZE_CHECK}" ]; then
		print_usage "Invalid part size specified: ${2} (valid examples: '1024', '1024k', or '500m')"
	fi

	FILES="${3}"
	if [ -d "${3}" ]; then
		FILES=( "${3}/"* )
	fi

	if [ "${#FILES[@]}" = "0" ]; then
		echo "No files to split were found."
		exit 1
	fi

	for FILE in "${FILES[@]}"; do
		# echo "file: ${FILE}"
		FILE_PART_CHECK=`echo "${FILE}" | egrep -v ".part...$"`
		if [ -z "${FILE_PART_CHECK}" ]; then
			echo "Not splitting part: ${FILE}"
			continue
		fi
		split_file ${2} "${FILE}"
	done
elif [ "join" = "${1}" ]; then
	if [ "${#}" != "2" ]; then
		print_usage "Invalid arguments specified. ('join' mode arguments: splitfiles.sh join [file or directory])"
	fi

	if [ -d "${2}" ]; then
		join_files "${2}" ""
	else 
		join_file "${2}" "${2}"
	fi
else 
	print_usage "Unsupported operation: ${1}"
fi

exit 0
