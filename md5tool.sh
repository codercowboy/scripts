#!/bin/bash

########################################################################
#
# md5tool.sh - md5 digest creation & validation script
#   written by Jason Baker (http://www.worldsworstsoftware.com)
#
########################################################################
#
# UPDATES:
#
# 2009/05/31
#  - Added "CREATEFOREACH" mode.
# 2007/02/12
#  - Moved the "creating md5" message below the code that removes pre-exising sumfiles
# 2006/10/26
#  - performance w/ openssl is horrible due to bash for loop, back to md5sum
# 2006/10/25
#  - rewrote to use openssl instead of md5sum
#  - script is now more verbose about whats going on & errors that occur
#  - added some error checking
#  - updated usage notes
# 2006/10/??
#  - merged both md5 scripts into md5tool.sh
# 2005/??/??
#  - initial version (two seperate files, one that checks, one that creates)
#
########################################################################
#
# thanks to http://www.franklinmint.fm/blog/archives/000831.html
# for the openssl output to md5sum output tip
#
# thanks to http://community.livejournal.com/unixadmin/83064.html
# for help w/ bash expression problems
#
# thanks to http://www.dbnet.ece.ntua.gr/~george/sed/OLD/sedfaq.html
# for help w/ sed
#
########################################################################

md5filename="checksum.md5"
exitstatus=0
oldpwd=`pwd`

#make for's argument seperator newline only
IFS=$'\n'

function print_usage()
{
  echo "md5tool.sh helps maintain file integrity through md5 digest files"
  echo
  echo "USAGE"
  echo "  md5tool.sh OPERATION PATH"
  echo
  echo "OPERATIONS"
  echo "  CREATE - create a $md5filename containing md5 values of files found in PATH"
  echo "  CREATEFOREACH - create a $md5filename for each child directory of PATH"
  echo "  CHECK - check the values in $md5filename against md5 values of files found in PATH"
  echo "  CHECKALL - check all $md5filename files found in PATH"
  echo
  echo "EXIT STATUS"
  echo "  0 - no errors occurred"
  echo "  1 - errors occurred"
  print_error "$1"
}

function print_error()
{
	echo
	echo "ERROR: $1"
	echo
	cd "$oldpwd"
	exit 1
}

function test_command_success()
{
	if test $? -ne 0
	then
		print_error "$1"
	fi
}

function create_md5()
{
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  cd "$completedpath" #change directory to the path to create checksum file in

  test_command_success "Could not switch CWD to: \"$completedpath\""

  if test -e "$md5filename"
  then
    echo "Removing Old $completedpath$md5filename"
    rm -f "$md5filename"
	test_command_success "Could not remove old checksum file."
  fi
  
  echo "Creating $completedpath$md5filename ... "

  touch "$md5filename"
  test_command_success "Could not create checksum file."

  if test ! -w "$md5filename"
  then
  	print_usage "Cannot write to checksum file."
  fi

  find . -type f -print0 | xargs -0 md5sum -b | grep -v $md5filename >> $md5filename

  cd "$oldpwd"
}

function create_md5_for_each_subdirectory()
{
	SUBDIRECTORIES=`find "$1" -maxdepth 1 -mindepth 1 -type d`
	for SUBDIRECTORY in $SUBDIRECTORIES
	do
		create_md5 "$SUBDIRECTORY"
	done
}

function check_md5()
{
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  cd "$completedpath" #change directory to the path to check from

  test_command_success "Could not switch CWD to: \"$completedpath\""

  echo "Checking $completedpath$md5filename ... "

  if test ! -e "$md5filename"
  then
  	echo "  Checksum file does not exist."
    exitstatus=1
    return
  elif test ! -r "$md5filename"
  then
  	echo "  Checksum file is not readable."
   	exitstatus=1
   	return
  fi

  md5sum -c "$md5filename" 2>&1 | grep -v ": OK"  | sed 's/^/    /g'

  cd "$oldpwd" #change directory back to where we were before
}

function check_all_md5()
{
  CHECKSUMFILES=`find "$1" -name "$md5filename"`
  for FILE in $CHECKSUMFILES
  do
    	check_md5 `dirname "$FILE"`
    	cd "$oldpwd"
  done
}


if test -z "$1" -o -z "$2"
then
  print_usage "Invalid arguments specified: operation: \"$1\" path: \"$2\""
fi

if test "$1" = "CREATE"
then
  create_md5 "$2"
elif test "$1" = "CREATEFOREACH"
then
  create_md5_for_each_subdirectory "$2"  
elif test "$1" = "CHECK"
then
  check_md5 "$2"
elif test "$1" = "CHECKALL"
then
  check_all_md5 "$2"
else
  #unknown operation specified
  print_usage "Unknown operation: \"$1\""
fi

if test $exitstatus -ne 0
then
	echo
	echo "ERRORS OCCURRED."
	echo
fi

cd "$oldpwd"

exit $exitstatus
