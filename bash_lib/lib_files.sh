#!/bin/bash

if [ "`type -t inspect_files`" = "function" ]; then
	echo "Skipping import functions from lib_files.sh, they're already sourced in this shell"
	return 0
fi

function count_files {
	# from: https://stackoverflow.com/questions/15216370/how-to-count-number-of-files-in-each-directory
	du -a | cut -d/ -f2 | sort | uniq -c | sort -nr
}
export -f count_files

function inspect_files {
	if [ "${1}" = "" -o "${2}" = "" ]; then
        echo "USAGE: inspect_files [path] [output file prefix]"
        return
    fi
	echo "Gathering checksum info to file: ${2}-checksums.txt"
	md5tool.sh DISPLAY "${1}" > "${2}-checksums.txt"	
	# reverses output, instead of "2G ./somefile" it is now "./somefile [2G]"
	local SED_COMMAND="sed -E 's/^[^[:digit:]]*//' | sed -E 's/[[:space:]]/::/' | sed -E 's/(.*)::(.*)/\2 [\1]/'"
	echo "Gathering dir info to file: ${2}-dirs.txt"
	eval "du -h \"${1}\" | ${SED_COMMAND}" > "${2}-dirs.txt"
	echo "Gathering file info w/ actual size to file: ${2}-files-real-size.txt"
	eval "du -a \"${1}\" | ${SED_COMMAND}" > "${2}-files-real-size.txt"
	echo "Gathering file info w/ summary size to file: ${2}-files-summary.txt"
	eval "du -a -h \"${1}\" | ${SED_COMMAND}" > "${2}-files-summary.txt"
}
export -f inspect_files

function move_files_here_fn {
	if [ "${1}" = "" ]; then
		echo "USAGE: move_files_here [source directory]"
		echo "  source directory is directory to find files in"
		echo "  files will be moved to current working directory"
		return
	fi

	local OLD_IFS=${IFS}
	IFS=$'\n'
	local FILES=`find "${1}" -type f | sort`
	local FILE_COUNT=`echo "${FILES}" | wc -l`
	echo "Moving ${FILE_COUNT} files to target directory `pwd -P`"
	for FILE in ${FILES}; do	
		echo "Moving: ${FILE}"	
		mv "${FILE}" .
	done
	IFS=${OLD_IFS}
}
alias move_files_here='move_files_here_fn ${1}'