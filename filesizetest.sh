#!/bin/bash

########################################################################
#
# filesizetest.sh - compare file sizes script
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
# 2006/10/25
#  - cleaned up usage
# 2006/10/12
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

function print_usage
{
	echo
	echo "filesizetest.sh compares two file sizes with the given operation"
	echo
	echo "USAGE"
	echo "  filesizetest.sh FILE_SIZE_1 OPERATION FILE_SIZE_2"
	echo
	echo "ARGUMENTS"
	echo "  FILE_SIZE_1 - the first file size to compare"
	echo "  OPERATION - the comparsion operation to perform"
	echo "  FILE_SIZE_2 - the second file size to compare"
	echo
	echo "VALID FILE SIZE SUFFIXES:"
	echo "  G - gigabyte (i.e. 12G)"
	echo "  K - kilobyte (i.e. 12K)"
	echo "  M - megabyte (i.e. 12M)"
	echo
	echo "  (File sizes without a suffix are assumed to be in bytes.)"
	echo
	echo "VALID OPERATIONS:"
	echo "  == - equals"
	echo "  != - does not equal"
	echo "  >  - is greater than"
	echo "  >= - is greater than or equal to"
	echo "  <  - is less than"
	echo "  <= - is less than or equal to"
	echo
	echo "EXIT STATUS:"
	echo "  1 - the operation returned true"
	echo "  0 - the operation returned false"
	echo "  2 - an error occurred"
	echo
	echo
	echo "  ERROR: $1"
	echo
	exit 2
}

kilobyte_size=1000
megabyte_size=$(( $kilobyte_size * 1000 ))
gigabyte_size=$(( $megabyte_size * 1000 ))

conversion_return="";

function convert_filesize_to_bytes()
{

	filesize="$1"

	filesizesuffix=`echo $filesize | grep -E -o '[A-Z]+'`

	filesize=`echo $filesize | grep -o '[0-9|\.]*'`

	if test -n "$filesizesuffix"
	then
		#filesize has an alphabetic suffix on it

		if test "$filesizesuffix" = "K"
		then
			filesize=`echo "$filesize*$kilobyte_size" | bc`
		elif test "$filesizesuffix" = "M"
		then
			filesize=`echo "$filesize*$megabyte_size" | bc`
		elif test "$filesizesuffix" = "G"
		then
			filesize=`echo "$filesize*$gigabyte_size" | bc`
		else
			echo "unknown file size suffix: $filesizesuffix"
		fi
	fi

	conversion_return="$filesize"
}

function validate_filesize()
{
	filesize=`echo $1 | grep -E -o '[0-9]+([\.][0-9]+)?[G|K|M]?'`
	if test -z $filesize
	then
		print_usage "Invalid file size: \"$1\""
	fi
}

function validate_operation()
{
	op=`echo $1 | grep -E -o '^(==|!=|<|<=|>|>=)$'`
	if test -z $op
	then
		print_usage "Invalid operation: \"$1\""
	fi
}

if test ! $# -eq 3
then
   print_usage "Invalid number of arguments specified."
fi

#validate the arguments
validate_filesize $1
validate_operation $2
validate_filesize $3

#convert each filesize to bytes
convert_filesize_to_bytes "$1"
filesize1=$conversion_return

convert_filesize_to_bytes "$3"
filesize2=$conversion_return

#do the test w/ bc
exitcode=`echo "$filesize1 $2 $filesize2" | bc`

#exit with the correct code
if test $exitcode = "1"
then
	exit 1
elif test $exitcode = "0"
then
	exit 0
else
	exit 2
fi


