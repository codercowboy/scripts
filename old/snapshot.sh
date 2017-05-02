#!/bin/bash

########################################################################
#
# snapshot.sh creates and removes dated snapshot directories
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
#
# UPDATES:
#
# 2007/1/27
#  - fixed some issue with unquoted arguments containing spaces
#
# 2006/10/25
#  - updated usage
#
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


function print_usage()
{
  echo "snapshot.sh creates and removes dated snapshot directories"
  echo
  echo "USAGE"
  echo "  snapshot.sh OPERATION PATH"
  echo
  echo "ARGUMENTS"
  echo "  OPERATION - the operation to perform"
  echo "  PATH - the path to create or deleted snapshot directores from"
  echo
  echo "VALID OPERATIONS"
  echo "  CREATE - Create snapshot directory for today,"
  echo "           and print the directory name to stdout"
  echo
  echo "  CREATECLEAN - Same as CREATE, except clean out "
  echo "                contents if the dir already exists"
  echo
  echo "  DELETE N - Delete snapshot directories, "
  echo "             but save latest N of them"
  echo
  echo
  echo "  ERROR: $1"
  echo
  exit 1
}

function test_directory_exists()
{
  if test ! -d "$1"
    then
      print_usage "Directory Not Found: $1"
  fi
}

function test_is_numeric()
{
  NUM=`echo "$1" | grep '^[0-9]\+$'`
  if test -z $NUM
  then
    print_usage "\"$1\" is not a number."
  fi
}

function clear_snapshots()
{
  # arg 1 = path to clear snapshots from
  # arg 2 = directories to save

  DIRECTORIES=`find "$1" -maxdepth 1 -mindepth 1 -type d | sort`

  #make for's argument seperator newline only
  IFS=$'\n'

  DIRECTORIES_TO_SAVE=$2

  COUNT=0

  for DIRECTORY in $DIRECTORIES
  do
    COUNT=$(( $COUNT + 1 ))
  done

  COUNT=$(( $COUNT - $DIRECTORIES_TO_SAVE ))

  for DIRECTORY in $DIRECTORIES
  do
    if test $COUNT -gt 0
    then
      echo "removing old snapshot \"$DIRECTORY\""
      rm -Rf "$DIRECTORY"
      COUNT=$(( $COUNT - 1 ))
    else
      break
    fi
  done

}

function create_snapshot()
{
  # arg 1 = path name to create snapshot in
  # arg 2 = "CLEAN" if snapshot should be cleaned out

  TODAY=`date +"%Y%m%d"`

  COMPLETED_PATH="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  NEW_SNAPSHOT_DIR="$COMPLETED_PATH$TODAY"

  if test ! -d "$NEW_SNAPSHOT_DIR"
  then
    mkdir "$NEW_SNAPSHOT_DIR"
  fi

  if test "$2" = "CLEAN"
  then

    #
    #  thanks to the unixadmin livejournal community for help on this bit below
    #  http://community.livejournal.com/unixadmin/82573.html
    #

    find "$NEW_SNAPSHOT_DIR/" -maxdepth 1 -mindepth 1 -print0 | xargs -0 rm -rf
  fi

  echo "$NEW_SNAPSHOT_DIR"
}

if test -z $1
then
   print_usage "No arguments specified."
fi

if test $1 = "CREATE"
then

  test_directory_exists "$2"
  create_snapshot "$2"

elif test $1 = "CREATECLEAN"
then

  test_directory_exists "$2"
  create_snapshot "$2" "CLEAN"

elif test $1 = "DELETE"
then

  test_is_numeric "$2"
  test_directory_exists "$3"
  clear_snapshots "$3" "$2"

else

  print_usage "Unsupported Operation: $1"

fi

exit 0
