#!/bin/bash

########################################################################
#
# fp.sh - file detail printing utilities
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2021/2/12
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
	echo "fp.sh - file detail printing utilities"
	echo
	echo "USAGE"
	echo "  fp.sh OPERATION PATH"
	echo
	echo "ARGUMENTS"
	echo "  OPERATION - one of: size, size_rounded, checksum, mod_time, summary"
	echo "  PATH - the path to file or directory to check"
	echo
	echo "NOTES"
	echo "  Specifying a directory will result in checking all files in the directory."
	echo
	echo
	echo "  ERROR: $1"
	exit 1
}

OPERATION="${1}"
FILE_PATH="${2}"

if [ -z "${1}" -o -z "${2}" ]; then
	print_usage "Invalid arguments specified."
elif [ "${1}" != "size" -a "${1}" != "size_rounded" -a "${1}" != "checksum" -a "${1}" != "mod_time" -a "${1}" != "summary" ]; then 
	print_usage "Invalid operation specified: ${OPERATION}"
elif [ ! -d "${FILE_PATH}" -a ! -f "${FILE_PATH}" ]; then
	print_usage "${FILE_PATH} is not a file or directory."
fi

# arg 1 is file path
# output is exact file size such as "12345"
function print_file_size {
	if [ -d "${1}" ]; then
		find "${1}" -type f -print0 | xargs -0 stat -f %z | awk '{t+=$1}END{print t}'
		return
	fi
	stat -f %z "${1}"
}

# arg 1 is file path
# output is file's mod time size such as "Feb 12 12:34:57 2021"
function print_file_mod_time {
	stat -f %Sm "${1}"
}

# arg 1 is file path
# output is summarized file size such as "12K"
function print_file_size_rounded {
	if [ -d "${1}" ]; then
		du -h -d 0 "${1}" | tail -n 1 | sed 's/^ //' | sed 's/[[:space:]].*//'
		return
	fi
	du -h "${1}" | sed 's/^ //' | sed 's/[[:space:]].*//'
}

# arg 1 is file path
# output is md5 checksum such as "3c25f19b837bff37faa72cece5763d84"
function print_file_checksum {
	if [ -d "${1}" ]; then
		echo "(No Checksum)"
		return
	fi
	md5sum "${1}" | sed 's/[[:space:]].*//'
}

# accumulate list of files to check
FILES="${FILE_PATH}"
IS_DIRECTORY=false
if [ -d "${FILE_PATH}" ]; then
	FILES=`find "${FILE_PATH}"`
	if [ -z "${FILES}" ]; then
		print_usage "${FILE_PATH} directory does not contain any files"
		IS_DIRECTORY=true
	fi
fi

#make for's argument seperator newline only
oIFS=${IFS}
IFS=$'\n'

for FILE in ${FILES}; do
	if [ -z "${FILE}" -o "." = "${FILE}" -o ".." = "${FILE}" ]; then
		continue
	fi
	if [ "${OPERATION}" = "size" ]; then
		OUTPUT=`print_file_size "${FILE}"`		
	elif [ "${OPERATION}" = "size_rounded" ]; then
		OUTPUT=`print_file_size_rounded "${FILE}"`
	elif [ "${OPERATION}" = "checksum" ]; then
		OUTPUT=`print_file_checksum "${FILE}"`
	elif [ "${OPERATION}" = "mod_time" ]; then
		OUTPUT=`print_file_mod_time "${FILE}"`
	elif [ "${OPERATION}" = "summary" ]; then
		FILE_SIZE=`print_file_size "${FILE}"`
		FILE_SIZE_SIMPLE=`print_file_size_rounded "${FILE}"`
		FILE_CHECKSUM=`print_file_checksum "${FILE}"`
		FILE_MOD_TIME=`print_file_mod_time "${FILE}"`
		OUTPUT="${FILE_SIZE} [${FILE_SIZE_SIMPLE}] :: ${FILE_CHECKSUM} :: ${FILE_MOD_TIME}"
	fi
	
	if [ ${IS_DIRECTORY} = true -o "${OPERATION}" = "summary" ]; then
		echo "${FILE} :: ${OUTPUT}"
	else
		echo "${OUTPUT}"
	fi
done

IFS=${oIFS}
