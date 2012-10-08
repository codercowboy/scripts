#!/bin/bash

########################################################################
#
# renameit.sh - rename image files w/ a timestamp based on last modified time
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
# 2009/03/30
#  - changed script to prepend date rather than replace original filename entirely
# 2008/12/29
#  - changed script to use jhead instead of find if jhead is available
# 2008/7/6
#  - added appender argument
# 2008/5/19
#  - fixed bug where some versions of find have decimal places in 
#    seconds field, now decimal and following digits are truncated.
# 2007/11/17
#  - safer file existence checking
# 2007/02/12
#  - fixed bug with multiple periods in file name or path name
# 2006/10/25
#  - updated usage info
#  - replaced dos2unix usage w/ tr
#  - cleaned up some test statements
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


function print_usage()
{
	echo "renameit.sh - rename files w/ a timestamp based on file's last modified time"
	echo
	echo "USAGE"
	echo "  renameit.sh PATH APPENDER"
	echo
	echo "ARGUMENTS"
	echo "  PATH - the path to files to check"
	ecgo "  APPENDER - a string to append before the file extension on each file"
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

APPENDER="$2"

FILE_COUNTER=1

BASE_PATH="${1%*/}/" #this will put a / on the end of the path if there isnt one already

#
# thanks to http://www.vasudevaservice.com/documentation/how-to/converting_dos_and_unix_text_files
# for help w/ dos2unix to TR convert tip
#

FILES=`find "$1" -maxdepth 1 -type f -name '*' | sort | tr -d '\15\32'`

#make for's argument seperator newline only
IFS=$'\n'

for FILE in $FILES
do
	echo "current file: $FILE"
	ORIGINAL_BASENAME=`basename "$FILE"`
	
	FILE_DATE=""
	
	#jhead prints a line such as "File date    : 2008:11:02 09:21:34" as well as other meta info
	# grep is going to filter lines that don't match "File date"
	# the sed regex "s/^[^:]*:.//g" is going to remove everything before the 2008 in the example above
	# the sed regex "s/://g" is going to remove any colons from the date
	FILE_DATE=`jhead "$FILE" | grep "Date/Time" | sed "s/^[^:]*:.//g;s/://g"`
	
	#if jhead failed or doesnt exist then try to use find to use the last mod time of the file..
	
	if test -z "$FILE_DATE"
	then
		FILE_DATE=`find "$FILE" -printf "%TY%Tm%Td %TH%TM%TS"` #old find expression to 
		    	
		SECONDS_DECIMAL_PLACE=`expr index "$FILE_DATE" .`
		    	
		if [ $SECONDS_DECIMAL_PLACE -gt 0 ]
		then
			#there is a decimal place in this version of find's second operator
			# remove the decimal and everything following the decimal

			SECONDS_DECIMAL_PLACE=$(( SECONDS_DECIMAL_PLACE - 1 ))
			FILE_DATE=`expr substr "$FILE_DATE" 1 $SECONDS_DECIMAL_PLACE`
			#echo "NEW FILE DATE: $FILE_DATE"
	    	fi
	fi
	
	#if we still don't have a date, don't rename it..	    	    	   
	
	if test -z "$FILE_DATE"
	then
		echo "  Not renaming file, we couldn't find a date to rename it with."
	else
		NEW_FILE="${BASE_PATH}${FILE_DATE}${APPENDER} ${ORIGINAL_BASENAME}"
		
		#make sure a file with the new name doesn't already exist
		
		echo "  trying $NEW_FILE"
		while [ -e "$NEW_FILE" ]
		do
		  echo "  file $NEW_FILE already exists, trying something else.."
		  #the file already exists, lets try to make it unique..
		  NEW_FILE="${BASE_PATH}${FILE_DATE}${APPENDER} ${FILE_COUNTER} ${ORIGINAL_BASENAME}"
		  ((FILE_COUNTER=FILE_COUNTER + 1))
		  echo "  trying $NEW_FILE"
		done
			
		FILE_COUNTER=1;
			
		echo "  Renaming File: $FILE"
		echo "    to: $NEW_FILE"
		echo
		
		mv "$FILE" "$NEW_FILE"	
	
	fi
	
	
done
