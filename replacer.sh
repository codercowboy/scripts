#!/bin/bash

if [ "" = "${1}" -o "" = "${2}" -o "" = "${3}" ]; then
	echo "USAGE: replacer.sh [Directory] [Search String] [Replace String]"
	echo ""
	echo "  NOTE: Search/Replace strings need to be sed-compatible regexes."
	exit 1
fi

DIRECTORY="${1}"
SEARCH_STRING="${2}"
REPLACE_STRING="${3}"

echo "Replacing '${SEARCH_STRING}' with '${REPLACE_STRING}'"

echo "Finding files in '${DIRECTORY}'"

if [ ! -d "${DIRECTORY}" ]; then
	echo "ERROR: Directory '${DIRECTORY}' does not exist"
	exit 1
fi

#make for's argument seperator newline only
IFS=$'\n'

FILES=`find "${DIRECTORY}" -type f | sort | grep -v ".git"`
FILE_COUNT=`echo "${FILES}" | wc -l | sed 's/[^0-9]*//'`

if [ "0" = "${FILE_COUNT}" ]; then
	echo "No files were found in directory '${DIRECTORY}', stopping."
	exit 0
fi

echo "Found ${FILE_COUNT} files."


CHANGED_FILE_COUNT=0
CHANGED_FILES=""

for FILE in `echo "${FILES}"`; do
	# if a file has a $ in it (like wicket html files), escape them
	FILE="${FILE//$/\\$}"	

	# echo "Processing File: ${FILE}"

	# count lines that match this
	TMP_COMMAND="cat \"${FILE}\" | grep \"${SEARCH_STRING}\" | wc -l | sed 's/[^0-9]*//'"
	#echo "COMMAND: ${TMP_COMMAND}"
	MATCHING_LINE_COUNT=`eval "${TMP_COMMAND}"`
	if [ "0" = "${MATCHING_LINE_COUNT}" ]; then
		#echo "No matches found in this file, skipping: ${FILE}"
		continue
	fi
	echo "Replacing ${MATCHING_LINE_COUNT} matching lines found in this file: ${FILE}"
	CHANGED_FILE_COUNT=$((CHANGED_FILE_COUNT+1))

	# do replacement, put in "${FILE}.new"
	TMP_COMMAND="cat \"${FILE}\" | sed 's/${SEARCH_STRING}/${REPLACE_STRING}/' > \"${FILE}.new\""
	#echo "COMMAND: ${TMP_COMMAND}"
	eval "${TMP_COMMAND}"

	# replace old file with contents of "${FILE}.new"
	TMP_COMMAND="mv \"${FILE}.new\" \"${FILE}\""
	#echo "COMMAND: ${TMP_COMMAND}"
	eval "${TMP_COMMAND}"

	# append file's path to list of changed files
	if [ "" = "${CHANGED_FILES}" ]; then
		CHANGED_FILES="${FILE}"
	else
		CHANGED_FILES=`echo "${CHANGED_FILES}" && echo "${FILE}"`
	fi	
done

echo "Changes were made to ${CHANGED_FILE_COUNT} of ${FILE_COUNT} files."
if [ "" != "${CHANGED_FILES}" ]; then
	echo "Changed files:"
	echo
	echo "${CHANGED_FILES}"
fi
echo

exit 0
