#!/bin/bash

if [ "`type -t zip_each`" = "function" ]; then
	echo "Skipping import functions from lib_zip_helpers.sh, they're already sourced in this shell"
	return 0
fi

#####################
# TAR/ZIP FUNCTIONS #
#####################

# arg 1 = command to run ie "zip -r"
# arg 2 = description ie "Zipping"
# arg 3 = file extension for file ie "zip" or "tar"
# arg 4 = path to process files in
function zip_process_each_file {
	if [ -z "${1}" -o -z "${2}" -o -z "${3}" -o -z "${4}" ]; then
		echo "USAGE: process_each_file [COMMAND] [DESCRIPTION] [ARCHIVE FILE EXTENSION] [DIRECTORY]"
		echo "\tThis will archive each file (or directory) in the given directory."
		return
	fi
	OLD_IFS=${IFS}
	IFS=$'\n'
	OLD_CWD=`pwd -P`
	cd "${4}"
	FILES=`find . -maxdepth 1 | sort`
	for FILE in ${FILES}; do
		if [ "." = "${FILE}" -o ".." = "${FILE}" ]; then
			continue
		fi
		ORIGINAL_BASENAME=`basename "${FILE}"`
		NEW_FILE="${ORIGINAL_BASENAME}.${3}"
		echo "${2} ${FILE} to ${NEW_FILE}"
		CMD="${1} \"${NEW_FILE}\" \"${FILE}\""
		echo "Executing: ${CMD}"
		eval "${CMD}"
	done
	IFS=${OLD_IFS}
	cd "${OLD_CWD}"
}
export -f zip_process_each_file

function zip_each {
	if [ -z "${1}" ]; then
		echo "USAGE: zip_each [DIRECTORY]"
		echo "  This will zip each file (or directory) in the given directory."
		return
	fi
	zip_process_each_file "zip -r" "Zipping" "zip" "${1}"
}
export -f zip_each

function tar_each {
	if [ -z "${1}" ]; then
		echo "USAGE: tar_each [DIRECTORY]"
		echo "  This will tar (without gzip) each file (or directory) in the given directory."
		return
	fi
	zip_process_each_file "tar cvf" "Tarring" "tar" "${1}"
}
export -f tar_each

function targz_each {
	if [ -z "${1}" ]; then
		echo "USAGE: targz_each [DIRECTORY]"
		echo "  This will tar (with gzip) each file (or directory) in the given directory."
		return
	fi
	zip_process_each_file "tar cvfz" "Tarring" "tar.gz" "${1}"
}
export -f targz_each

function untar_each {
	if [ -z "${1}" ]; then
		echo "USAGE: untar_each [DIRECTORY]"
		echo "  This will untar each tar in the given directory."
		return
	fi
	cd "${1}" && find . -iname \*.tar\* -exec tar -xvf {} \;
	cd -
}

export -f targz_each

function 7z_each {
	if [ -z "${1}" ]; then
		echo "USAGE: 7z_each [DIRECTORY]"
		echo "  This will 7zip (with lzma2) each file (or directory) in the given directory."
		return
	fi

	# example: 7z a -r -t7z -m0=lzma2 -mx=9 -mfb=273 -md=1g -ms=10g -mmt=off -mmtf=off -mqs=on -bt -bb3 archife_file_name.7z /path/to/files
	# argument explanations from https://stackoverflow.com/a/52771612
	#   a - add files to archive
	#   -r - Recurse subdirectories
	#   -t7z - Set type of archive (7z in your case)
	#   -m0=lzma2 - Set compression method to LZMA2
	#   -mx=9 - Sets level of compression. x=9 - Ultra
	#   -mfb=273 - Sets number of fast bytes for LZMA. 
	#   -md=4g - Sets Dictionary size for LZMA
	#   -ms=8g - Enables solid mode w/ 8g block size - might decrease compression ratio
	#   -mqs=on - Sort files by type in solid archives. To store identical files together.
	#   -mmt=off - Sets multithreading mode to OFF. 
	#   -mmtf=off - Set multithreading mode for filters to OFF.
	#   -myx=9 - Sets level of file analysis to maximum, analysis of all files (Delta and executable filters).
	#   -bt - show execution time statistics
	#   -bb3 - set output log level 

	#CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mx=9 -mfb=273 -md=1g -ms=4g -mmt=off -mmtf=off -mqs=on -bt -bb3"
	#CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mfb=273 -md=1g -ms=2g -mqs=on -bt -bb3"
	CMD_PREFIX="7z a -r -t7z -m0=lzma2 -mmt=off -mmtf=off -mqs=on -bt -bb3"
	zip_process_each_file "${CMD_PREFIX}" "7Zipping" "7z" "${1}"
}
export -f 7z_each
