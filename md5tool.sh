#!/bin/bash

########################################################################
#
# md5tool.sh - md5 digest creation & validation script
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
# - Removed "Update" mode due to numerous bugs. I'll rewrite it in Java.
#
# 2016/04/14
# - Added "Update", "Remove All", "Join All" modes.
# - Cleaned up code a bit.
# - NOTE: I've only tested this iteration on OSX, email me if problems.
#
# 2009/05/31
#  - Added "CREATEFOREACH" mode.
#
# 2007/02/12
#  - Moved the "creating md5" message below the code that removes pre-exising sumfiles
#
# 2006/10/26
#  - performance w/ openssl is horrible due to bash for loop, back to md5sum
#
# 2006/10/25
#  - rewrote to use openssl instead of md5sum
#  - script is now more verbose about whats going on & errors that occur
#  - added some error checking
#  - updated usage notes
#
# 2006/10/??
#  - merged both md5 scripts into md5tool.sh
#
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
# thanks to http://www.stackoverflow.com 
# for a million answers
# 
# thanks to http://tldp.org/
# for the advanced bash scripting guide
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

md5filename="checksum.md5"
exitstatus=0

#make for's argument seperator newline only
IFS=$'\n'

function print_usage() {
  echo "md5tool.sh helps maintain file integrity through md5 digest files"
  echo
  echo "USAGE"
  echo "  md5tool.sh OPERATION PATH"
  echo
  echo "OPERATIONS"
  echo "  CREATE - create a $md5filename containing md5 values of files found in PATH"
#  echo "  UPDATE - update ${md5filename} and compare with previous checksums"
  echo "  CREATEFOREACH - create a $md5filename for each child directory of PATH"
  echo "  CHECK - check the values in $md5filename against md5 values of files found in PATH"
  echo "  CHECKALL - check all $md5filename files found in PATH"
  echo "  JOINALL - join all $md5filename files found in PATH"
  echo "  JOINALLREMOVEOLD - join all $md5filename files found in PATH, files found are removed"
  echo "  REMOVEALL - remove all $md5filename files found in PATH"
  echo "  DISPLAY - display info for all $md5filename files found in PATH"
  echo
  echo "EXIT STATUS"
  echo "  0 - no errors occurred"
  echo "  1 - errors occurred"
  print_error "$1"
}

function print_error() {
	echo
	echo "ERROR: $1"
	echo
	exit 1
}

function test_command_success() {
	if test $? -ne 0; then
		print_error "$1"
	fi
}

function create_md5() {
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  CHECKSUM_FILE="${completedpath}${md5filename}"

  if test -e "${CHECKSUM_FILE}"; then
    echo "Removing Old ${CHECKSUM_FILE}"
    rm "${CHECKSUM_FILE}"
    test_command_success "Could not remove old checksum file: ${CHECKSUM_FILE}"
  fi
  
  echo "Creating ${CHECKSUM_FILE} ... "

  touch "${CHECKSUM_FILE}"
  test_command_success "Could not create checksum file: ${CHECKSUM_FILE}"

  if test ! -w "${CHECKSUM_FILE}"; then
  	print_usage "Cannot write to checksum file: ${CHECKSUM_FILE}"
  fi

  cd "$completedpath" && find . -type f -print0 | xargs -0 md5sum -b | grep -v "${md5filename}" >> "${md5filename}"
  test_command_success "Could not create checksum file: ${CHECKSUM_FILE}"
  cd - > /dev/null
  CHECKSUM_FOR_FILE=$(md5sum "${completedpath}${md5filename}")
  echo "${CHECKSUM_FOR_FILE}"  
}

function create_md5_for_each_subdirectory() {
	SUBDIRECTORIES=`find "$1" -maxdepth 1 -mindepth 1 -type d`
	for SUBDIRECTORY in ${SUBDIRECTORIES}; do
		create_md5 "${SUBDIRECTORY}"
	done
}

function check_md5() {
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  CHECKSUM_FILE="${completedpath}${md5filename}"

  echo "Checking ${CHECKSUM_FILE} ... "

  if test ! -e "${CHECKSUM_FILE}"; then
  	echo "Checksum file does not exist: ${CHECKSUM_FILE}"
    exitstatus=1
    return
  elif test ! -r "${CHECKSUM_FILE}"; then
  	echo "Checksum file is not readable: ${CHECKSUM_FILE}"
   	exitstatus=1
   	return
  fi

  cd "${completedpath}" && md5sum -c "${md5filename}" 2>&1 | grep -v ": OK"  | sed 's/^/    /g'
  test_command_success "Could not check checksum file: ${CHECKSUM_FILE}"
  cd - > /dev/null
}

function check_all_md5() {
  for FILE in `find "${1}" -name "${md5filename}"`; do
    	check_md5 `dirname "${FILE}"`
  done
}

# arg 1 old md5 file
# arg 2 is new md5 file
function diff_md5() {
  if test ! -r "${1}"; then
    echo "Cannot compare md5 files, checksum file does not exist, or is not readable: (${1})"
    exitstatus=1
    return
  fi
  if test ! -r "${2}"; then
    echo "Cannot compare md5 files, checksum file does not exist, or is not readable: (${2})"
    exitstatus=1
    return
  fi

  echo
  echo "Comparing checksum files."
  echo "  Old checksum file: ${1}"
  echo "  New checksum file: ${2}"
  echo 

  DIFF_FILE="${2}.diff"
  DIFF_FILE_TMP="${2}.diff.tmp"

  if test -e "${DIFF_FILE}"; then
    echo "Removing old diff file: ${DIFF_FILE}"
    rm "${DIFF_FILE}"
  fi

  if test -e "${DIFF_FILE_TMP}"; then
    echo "Removing old diff file: ${DIFF_FILE_TMP}"
    rm "${DIFF_FILE_TMP}"
  fi

  # diff, and reformat lines to be file name first, and sorted
  # example line before: b6eae282641b9f697834701afee923fb *./testfile0a.bin
  # example line after: ./testfile0a.bin ### < b6eae282641b9f697834701afee923fb
  diff "${1}" "${2}" | grep " \*." | sed 's/\(.*\) \*\(\..*\)/\2 ### \1/' | sort > "${DIFF_FILE}"

  #TODO: what do we do if diff has no output?

  CHANGED_COUNTER=0
  ADDED_COUNTER=0
  DELETED_COUNTER=0
  RENAMED_COUNTER=0
  
  LAST_FILE_NAME=""
  LAST_FILE_CHECKSUM=""
  LAST_FILE_LINE=""
  for FILE_LINE in `cat "${DIFF_FILE}"`; do
    # example input line: ./testfile0a.bin ### < b6eae282641b9f697834701afee923fb
    FILE_NAME=`echo "${FILE_LINE}" | sed 's/\(.*\) ###.*/\1/'`
    FILE_CHECKSUM=`echo "${FILE_LINE}" | sed 's/.*### . \(.*\)/\1/'`
    #echo "line: ${FILE_LINE}"
    #echo "current: (${FILE_NAME}) (${FILE_CHECKSUM})"    
    if test "${LAST_FILE_LINE}" = ""; then
      # last file not hung onto, hang on to this round
      LAST_FILE_NAME="${FILE_NAME}"
      LAST_FILE_CHECKSUM="${FILE_CHECKSUM}"
      LAST_FILE_LINE="${FILE_LINE}"
    elif test "${LAST_FILE_NAME}" = "${FILE_NAME}"; then
      # last file and this file match name, checksum changed
      echo "Changed ${FILE_NAME} (checksum: ${LAST_FILE_CHECKSUM} to ${FILE_CHECKSUM})" 
      let CHANGED_COUNTER=CHANGED_COUNTER+1 
      LAST_FILE_LINE=""
    else
      # last file and this file's name don't match, save this case for later
      echo "${LAST_FILE_LINE}" >> "${DIFF_FILE_TMP}"
      LAST_FILE_NAME="${FILE_NAME}"
      LAST_FILE_CHECKSUM="${FILE_CHECKSUM}"
      LAST_FILE_LINE="${FILE_LINE}"
    fi
  done

  #save last line it it wasnt handled
  if test "${LAST_FILE_LINE}" != ""; then
    echo "${LAST_FILE_LINE}" >> "${DIFF_FILE_TMP}"
  fi  

  if test -e "${DIFF_FILE_TMP}"; then 
    # reformat saved lines from original diff to be checksum first
    # example line before: ./testfile0a.bin ### < b6eae282641b9f697834701afee923fb
    # example line after: b6eae282641b9f697834701afee923fb ### ./testfile0a.bin ### < 
    # BUG: shouldn't we sort here before outputing to DIFF_FILE ??
    cat "${DIFF_FILE_TMP}" | sed 's/\(.*### . \)\(.*\)/\2 ### \1/' > "${DIFF_FILE}"
    rm "${DIFF_FILE_TMP}"  

    LAST_FILE_NAME=""
    LAST_FILE_CHECKSUM=""
    LAST_FILE_LINE=""
    for FILE_LINE in `cat "${DIFF_FILE}"`; do
      FILE_NAME=`echo "${FILE_LINE}" | sed 's/.*### \(.*\) ###.*/\1/'`
      FILE_CHECKSUM=`echo "${FILE_LINE}" | sed 's/\(.*\) ###.*###.*/\1/'`
      #echo "line: ${FILE_LINE}"
      #echo "current: (${FILE_NAME}) (${FILE_CHECKSUM})" 
      if test "${LAST_FILE_LINE}" = ""; then
        # last file not hung onto, hang on to this one
        LAST_FILE_NAME="${FILE_NAME}"
        LAST_FILE_CHECKSUM="${FILE_CHECKSUM}"
        LAST_FILE_LINE="${FILE_LINE}"
      elif test "${LAST_FILE_CHECKSUM}" = "${FILE_CHECKSUM}"; then
        # last file and this file match name, file name changed
        echo "Renamed: ${FILE_NAME} (from: ${LAST_FILE_NAME})"
        let RENAMED_COUNTER=RENAMED_COUNTER+1 
        LAST_FILE_LINE=""
      else
        # last file and this file's checksum don't match, it was added or deleted
        DIFF_ARROW=`echo ${LAST_FILE_LINE} | sed 's/.*###.*### \(.\)./\1/'`      
        #echo "arrow: (${DIFF_ARROW})"
        if test "${DIFF_ARROW}" = "<"; then        
          echo "Deleted: ${LAST_FILE_NAME}"
          let DELETED_COUNTER=DELETED_COUNTER+1 
        else
          echo "Added: ${LAST_FILE_NAME}"
          let ADDED_COUNTER=ADDED_COUNTER+1 
        fi
        LAST_FILE_NAME="${FILE_NAME}"
        LAST_FILE_CHECKSUM="${FILE_CHECKSUM}"
        LAST_FILE_LINE="${FILE_LINE}"
      fi
    done # end for each line

    if test "${LAST_FILE_LINE}" != ""; then
      DIFF_ARROW=`echo ${LAST_FILE_LINE} | sed 's/.*###.*### \(.\)./\1/'`      
      #echo "arrow: (${DIFF_ARROW})"
      if test "${DIFF_ARROW}" = "<"; then
        echo "Deleted: ${LAST_FILE_NAME}"
        let DELETED_COUNTER=DELETED_COUNTER+1 
      else
        echo "Added: ${LAST_FILE_NAME}"
        let ADDED_COUNTER=ADDED_COUNTER+1 
      fi
    fi #end handling last line if it was left over 
  fi #end if for tmp file with remaining add/delete/remove lines was there
  
  rm "${DIFF_FILE}"

  echo
  echo "Comparison stats:"
  echo "  Files Changed: ${CHANGED_COUNTER}"
  echo "  Files Deleted: ${DELETED_COUNTER}"
  echo "  Files Renamed: ${RENAMED_COUNTER}"
  echo "  Files Added: ${ADDED_COUNTER}"
  echo

  COUNTER_CHECK="${CHANGED_COUNTER}${DELETED_COUNTER}"
  if test "${COUNTER_CHECK}" = "00"; then
    echo "Comparison result: SUCCESS! 0 files were changed."
  else
    let SUM=CHANGED_COUNTER+DELETED_COUNTER
    echo "Comparison result: FAILURE. ${SUM} files were changed or deleted."
    exitstatus=1
  fi  
}

# arg 1 is directory to update checksum in
function update_md5 {  
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  CHECKSUM_FILE="${completedpath}${md5filename}"
  echo "Updating checksum file: ${CHECKSUM_FILE}"
  create_md5 "${1}"
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  CHECKSUM_FILE="${completedpath}${md5filename}"
  if test "${exitstatus}" = "0"; then    
    diff_md5 "${CHECKSUM_FILE}.old" "${CHECKSUM_FILE}"  
  fi
}

# arg 1 is directory to update checksum in
# arg 2 is "true" if remove old checksum files
function join_all_md5 {
  completedpath="${1%*/}/" #this will put a / on the end of the path if there isnt one already
  CHECKSUM_FILE="${completedpath}${md5filename}"

  echo "Joining all checksum files to new file: ${CHECKSUM_FILE}"
  if test -e "${CHECKSUM_FILE}"; then
    echo "Renaming Old ${CHECKSUM_FILE} to ${CHECKSUM_FILE}.old"
    mv "${CHECKSUM_FILE}" "${CHECKSUM_FILE}.old"
    test_command_success "Could not remove old checksum file: ${CHECKSUM_FILE}"
  fi

  touch "${CHECKSUM_FILE}"

  for FILE in `find "${1}" -name "${md5filename}"`; do
    if test "${CHECKSUM_FILE}" = "${FILE}"; then
      continue;
    fi
    if test "`basename \"${FILE}\"`" != "${md5filename}.old"; then
      echo "Adding: ${FILE}"
      echo "# checksums originally from: ${FILE}" >> "${CHECKSUM_FILE}"

      # in the old file the paths were relative to that file's location
      # we need to extract that relative path to insert into the new files entries correctly
      #
      # example follows
      # old file: ./a/b/c/checksum.md5
      # new file: ./checksum.md5
      # old entry: c88e535dc21882efa9175a276c2821ee *./blah.bin
      # new entry: c88e535dc21882efa9175a276c2821ee *./a/b/c/blah.bin

      FIXED_RELATIVE_PATH="`dirname \"${FILE}\"`"      
      FIXED_RELATIVE_PATH=${FIXED_RELATIVE_PATH#$completedpath}
      for FILE_LINE in `cat ${FILE}`; do
        FILE_CHECKSUM="`echo "${FILE_LINE}" | sed 's/\(.*\) \*\..*/\1/'`"
        FILE_NAME="`echo "${FILE_LINE}" | sed 's/.* \*\.\(.*\)/\1/'`"
        # echo "# was: ${FILE_LINE}" >> "${CHECKSUM_FILE}"
        echo "${FILE_CHECKSUM} *./${FIXED_RELATIVE_PATH}${FILE_NAME}" >> "${CHECKSUM_FILE}"
      done
    fi
    if test "${2}" = "true"; then
      echo "Removing: ${FILE}"
      rm "${FILE}"
    fi
  done
}

function remove_all_md5 {
  echo "Removing all ${md5filename} files from ${1}"
  for FILE in `find "${1}" -name "${md5filename}"`; do
    echo "Removing ${FILE}"
    rm "${FILE}"
  done
}

function display_md5 {
  for FILE in `find "${1}" -name "${md5filename}"`; do
    FILE_DIR=`dirname "${FILE}"`
    DIR_SIZE=`du -h -d 0 "${FILE_DIR}" | sed -E 's/^[^[:digit:]]*//' | sed -E 's/[[:space:]].*//'`
    MD5_FOR_FILE=`md5sum "${FILE}" | sed -E 's/[[:space:]].*//'`
    echo "${FILE} [${DIR_SIZE}] ${MD5_FOR_FILE}" 
  done
}

# arg 1 is directory to run test in
function run_test() {
  TEST_DIR="${1}/md5tool-unittest"
  echo "Running md5tool.sh Unit Test in directory: ${TEST_DIR}"
  if test -e "${TEST_DIR}"; then
    echo "Removing pre-exising test data."
    rm -Rf "${TEST_DIR}"
  fi
  mkdir -p "${TEST_DIR}"
  COUNTER=0
  while [ ${COUNTER} -lt 10 ]; do
    openssl rand 1048576 > "${TEST_DIR}/testfile${COUNTER}.bin"
    let COUNTER=COUNTER+1 
  done
  
  md5tool.sh CREATE "${TEST_DIR}"
  md5tool.sh CHECK "${TEST_DIR}"
  md5tool.sh CHECKALL "${TEST_DIR}"
  COUNTER=0
  while [ ${COUNTER} -lt 4 ]; do
    #rm "${TEST_DIR}/testfile${COUNTER}.bin"
    openssl rand 1058576 > "${TEST_DIR}/testfile${COUNTER}.bin"
    openssl rand 1058576 > "${TEST_DIR}/testfile${COUNTER}a.bin"
    let COUNTER=COUNTER+1 
  done
  COUNTER=7
  mv "${TEST_DIR}/testfile${COUNTER}.bin" "${TEST_DIR}/testfile${COUNTER}r.bin"
  COUNTER=9
  mv "${TEST_DIR}/testfile${COUNTER}.bin" "${TEST_DIR}/testfile${COUNTER}r.bin"
  COUNTER=8
  rm "${TEST_DIR}/testfile${COUNTER}.bin"
  md5tool.sh UPDATE "${TEST_DIR}"
  md5tool.sh CHECK "${TEST_DIR}"
  md5tool.sh CHECKALL "${TEST_DIR}"

  md5tool.sh CREATE "${TEST_DIR}"
  md5tool.sh CHECK "${TEST_DIR}"
  md5tool.sh CHECKALL "${TEST_DIR}"

  echo
  echo "join test"
  mkdir -p "${TEST_DIR}/a"
  openssl rand 1048576 > "${TEST_DIR}/a/blah.bin"
  mkdir -p "${TEST_DIR}/b"
  openssl rand 1048576 > "${TEST_DIR}/b/blah.bin"
  mkdir -p "${TEST_DIR}/c/d/e/f"
  openssl rand 1048576 > "${TEST_DIR}/c/d/e/f/blah.bin"
  md5tool.sh CREATEFOREACH "${TEST_DIR}"
  md5tool.sh CREATEFOREACH "${TEST_DIR}/c/d/"  
  md5tool.sh JOINALL "${TEST_DIR}"
  echo "checksums:"
  cat "${TEST_DIR}/${md5filename}"
  md5tool.sh CHECKALL "${TEST_DIR}"

  echo
  echo "join test (remove all)"
  md5tool.sh JOINALLREMOVEOLD "${TEST_DIR}"
  md5tool.sh CHECKALL "${TEST_DIR}"

  echo
  echo "remove test"  
  md5tool.sh CREATEFOREACH "${TEST_DIR}"
  md5tool.sh REMOVEALL "${TEST_DIR}"
}


if test -z "$1" -o -z "$2"; then
  print_usage "Invalid arguments specified: operation: \"$1\" path: \"$2\""
fi

if test "$1" = "CREATE"; then
  create_md5 "$2"
elif test "$1" = "CREATEFOREACH"; then
  create_md5_for_each_subdirectory "$2"  
elif test "$1" = "CHECK"; then
  check_md5 "$2"
elif test "$1" = "CHECKALL"; then
  check_all_md5 "$2"
elif test "$1" = "UNITTEST"; then
  run_test "$2"
#elif test "$1" = "UPDATE"; then
#  update_md5 "$2"
elif test "$1" = "JOINALL"; then
  join_all_md5 "$2" "false"
elif test "$1" = "JOINALLREMOVEOLD"; then
  join_all_md5 "$2" "true"
elif test "$1" = "REMOVEALL"; then
  remove_all_md5 "$2"
elif test "$1" = "DISPLAY"; then
  display_md5 "$2"
else
  #unknown operation specified
  print_usage "Unknown operation: \"$1\""
fi

if test $exitstatus -ne 0; then
	echo
	echo "ERRORS OCCURRED."
	echo
fi

exit $exitstatus
