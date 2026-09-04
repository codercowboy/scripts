#!/bin/bash

#make for's argument seperator newline only
IFS=$'\n'

# arg 1 - dir to check
function should_backup_dir {	
	if [ -z "${1}" -o ! -d "${1}" ]; then
		echo "Error, not a dir: ${1} (not backing up)"
		return 1
	fi
	local CHECKSUM_FILE="${1}/checksum.md5"
	if [ ! -e "${CHECKSUM_FILE}" ]; then
		echo "Backing up '${1}', no checksum file: ${CHECKSUM_FILE}"
		$(cd "${1}" && find . -type f -print0 | xargs -0 md5sum -b | grep -v "checksum.md5" >> "checksum.md5")
		return 0
	fi
	local OLD_CHECKSUM=`md5sum "${CHECKSUM_FILE}"`
	rm "${CHECKSUM_FILE}"
	$(cd "${1}" && find . -type f -print0 | xargs -0 md5sum -b | grep -v "checksum.md5" >> "checksum.md5")
	local NEW_CHECKSUM=`md5sum "${CHECKSUM_FILE}"`

	if [ "${OLD_CHECKSUM}" != "${NEW_CHECKSUM}" ]; then
		echo "Backing up '${1}', checksum changed: ${OLD_CHECKSUM} -> ${NEW_CHECKSUM}"
		return 1;
	fi

	echo "Skipping '${1}', checksum is the same: ${OLD_CHECKSUM}"
	return 0
}

# arg 1 - root dir
function backup_dirs {
	local DATE=$(date +"%Y%m%d-%H%M%S")
	for CURRENT_DIR in `find . -type d -d 1`; do
		echo "Checking: ${CURRENT_DIR}"
		should_backup_dir "${CURRENT_DIR}"
		if [ "1" = "${?}" ]; then
			local TAR_FILE="${CURRENT_DIR}-${DATE}.tar.gz"
			echo "Backing up '${CURRENT_DIR}' to: ${TAR_FILE}"
			tar cfz "${TAR_FILE}" "${CURRENT_DIR}"
		else
			echo "Not creating backup for '${CURRENT_DIR}'"
		fi
	done
}

if [ -z "${1}" ]; then
	echo "USAGE: backupeach.sh [DIR] - reliably archives subfolders after changes "
	echo ""
	echo "Each subfolder of the given dir will be reliably archived if the subfolder's"
	echo "contents have changed since last backup. This is done using a checksum.md5 file"
	echo "that this tool puts in the root of the subfolder."
	echo ""
	echo "If the checksum file indicates changes have occurred, the folder is backed up"
	echo ""
	echo "EXAMPLES:"
	echo ""
	echo "File system: test-it/my folder/file.txt"
	echo "> backupeach test-it"
	echo "In this case if test-it/my folder had not been backed up before, 'my folder-<current date>.tar.gz' will be created in 'test-it'"
	exit 1
fi

backup_dirs "${1}"
exit 0