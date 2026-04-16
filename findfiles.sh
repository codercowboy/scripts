#!/bin/bash

# this is a hyper-specific one-off script that's probably not worth productizing made in March of 2026
# args: findfiles.sh [source dir] [target dir]
#
# what this script does is finds files non-recursively in source-dir then finds dupe files (recursively) in target dir
#
# 'finding a file' is simple filename match
#
# first an attempt will be made to find any dupes with exact file name, 
# then if none are found, an attempt is made with the filename with extension removed
#
# example:
#
# source file: /Users/jason/mysourcedir/10241215.jpg
# target dupe file #1: /Users/jason/targetdir/someotherdir/10241215.jpg # identical file match
# target dupe file #2: /Users/jason/targetdir/someotherdir2/10241215.jpg # identical file match, diff directory from previous
# target dupe file #3: /Users/jason/targetdir/someotherdir2/10241215.jpeg # note mismatched file extension
#
# in this example, if the dupe files #1 and #2 exist, they will printed out as dupes and dupe file #3 will not
# if, however, dupe files #1 AND #2 do not exist, current impl of the script will print dupe file #3 only
#
# copyright jason baker (jason@onejasonforsale) 2026

#make for's argument seperator newline only
IFS=$'\n'

SCRIPT_DIR=`dirname "${0}"`
SOURCE_DIR="${1}"
TARGET_DIR="${2}"
TARGET_FILES_LIST="${SCRIPT_DIR}/targetfileslist.txt"

echo "SCRIPT_DIR: ${SCRIPT_DIR}"
echo "SOURCE_DIR: ${SOURCE_DIR}"
echo "TARGET_DIR: ${TARGET_DIR}"
echo "TARGET_FILES_LIST: ${TARGET_FILES_LIST}"

find "${TARGET_DIR}" -type f | sort > "${TARGET_FILES_LIST}"

FILE_COUNT=0
FILES_WITH_DUPES_COUNT=0

for FILE in `find ${SOURCE_DIR} -type f | sort`; do
	((FILE_COUNT=FILE_COUNT + 1))
	FILENAME=`basename "${FILE}"`
	FILENAME_WITHOUT_EXTENSION="${FILENAME%%.*}" # example, blah.tar.sh -> blah
	echo "Current source file: ${FILE} (name: ${FILENAME}) (without extension: ${FILENAME_WITHOUT_EXTENSION})"  
	DUPE_COUNT=0

	for DUPE in `grep "${FILENAME}" "${TARGET_FILES_LIST}"`; do
		echo "Found dupe: ${DUPE}"
		((DUPE_COUNT=DUPE_COUNT + 1))	
	done

	if [ ${DUPE_COUNT} = "0" ]; then
		echo "Couldn't find dupes so far, trying without extension"
		for DUPE in `grep "${FILENAME_WITHOUT_EXTENSION}" "${TARGET_FILES_LIST}"`; do
		echo "Found dupe: ${DUPE}"
		((DUPE_COUNT=DUPE_COUNT + 1))	
	done

	fi

	if [ ${DUPE_COUNT} = "0" ]; then
		echo "Could not find dupes for ${FILE}"
	else
		((FILES_WITH_DUPES_COUNT=FILES_WITH_DUPES_COUNT + 1))		
		echo "Found ${DUPE_COUNT} dupes for ${FILE}"
	fi
	echo ""
done

NON_DUPE_FILE_COUNT=$((FILE_COUNT - FILES_WITH_DUPES_COUNT))
echo "Processed ${FILE_COUNT} files. ${FILES_WITH_DUPES_COUNT} had dupes, ${NON_DUPE_FILE_COUNT} did not have dupes."