#!/bin/bash

########################################################################
#
# processdiff.sh - print a user friendly version of diff's output
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 20??/??/??
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
	echo "processdiff.sh - print a user friendly version of diff's output"
	echo ""
	echo "USAGE:"
	echo "  processdiff.sh FILE1 FILE2"
	echo ""
	echo "    where FILE1 and FILE2 are the files to compare"
	echo ""
	echo "EXIT STATUS:"
	echo "  exit status will be 0 if files contain no differences"
	echo "  exit status will be non-zero if an error occurs or files contain differences"
	echo ""
	echo "ERROR:"
	echo "  $1"
}

function report_new_line()
{
	echo "New line in file 2: $1"
}

function report_deleted_line()
{
	echo "Deleted Line in File 1: $1"
}

function report_line_difference()
{
	echo "Line difference.."
	echo " File1: $1"
	echo " File2: $2"
}

function diff_files()
{
	DIFFOUTPUT=`diff "$1" "$2"`

	#TODO: check to make sure diff completed succesfully

	#make for's argument seperator newline only
	IFS=$'\n'

	DIFFEXITSTATUS=0 #1 signifies files are different

	LINE1=""
	LINE2=""

	for LINE in $DIFFOUTPUT
	do
		FIRSTCHAR=${LINE:0:1}
		case "$FIRSTCHAR" in

			 "<" )
				LINE1="$LINE"
				DIFFEXITSTATUS=1
			 ;;

			 ">" )
				LINE2="$LINE"
				DIFFEXITSTATUS=1
			 ;;

			 "-" )
				#do nothing in the "---" diff lines
			 ;;

			 * ) #catch all for everything else
				 if test ! -z "$LINE1" -a ! -z "$LINE2" #lines differ
				 then
					report_line_difference "$LINE1" "$LINE2"
				 elif test ! -z "$LINE1" -a -z "$LINE2" #line1 was deleted
				 then
					report_deleted_line "$LINE1"
				 elif test -z "$LINE1" -a ! -z "$LINE2" #line2 is new
				 then
					report_new_line "$LINE2"
				 fi

				 #reset the line variables
				 LINE1=""
				 LINE2=""

			 ;;

		esac
	done

	return $DIFFEXITSTATUS
}

if test -z "$1" -o -z "$2"
then
	print_usage "Invalid number of arguments specified"
	exit 1
fi

if test ! -r "$1"
then
	print_usage "Cannot open file for read: $1"
	exit 1
fi

if test ! -r "$2"
then
	print_usage "Cannot open file for read: $2"
	exit 1
fi

diff_files "$1" "$2"
exit $?