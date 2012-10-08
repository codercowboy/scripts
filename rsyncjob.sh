#!/bin/bash

########################################################################
#
# rsyncjob.sh - personal rsync job script
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
#
########################################################################
# 
# This script is provided as an example template for others to use with
# their own personal backup systems.
# 
# Note that the script depends on md5tool.sh and myrsync.sh in the 
# copy_local_backup_folder function.
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


MEDIA_SOURCE=/cygdrive/c/media/
LOCAL_BACKUP_DRIVE=/cygdrive/e
LOCAL_ARCHIVE_DRIVE=/cygdrive/f
USB_DRIVE=/cygdrive/z
BLUNX_INFO=jason@192.168.2.1

if [ -z "${1}" ]
then
	echo "Usage: rsyncjob.sh [job identifier(s)]"
	echo "  Job identifiers: (you can specify several in a row..)s"
	echo "     BACKUP-LOCAL - back up local files such as docs to local backup drive"
	echo "     BACKUP-SYNCH-REMOTE - synch down blunx and local backup up to blunx"
	echo "     BACKUP-E-TO-F - copy backup folder (and blunx backup) to F"
	echo "     ARCHIVE-E-TO-F - copy archive folder to F"
	echo "     MOVIES - backup movies from blunx to local"
	echo "     MEDIA-LOCAL - copy media from boot drive to backup drive"
	echo "     MEDIA-BLUNX - copy media from boot drive to blunx"
	echo "     USB-1TB - copy backup and media to 1TB usb drive"
	echo "     USB-300GB - copy other peoples stuff & media to 300GB usb drive"
	exit 0
fi

#arg1 is local folder to copy
function copy_local_backup_folder
{
	md5tool.sh CREATE "${1}"
	myrsync.sh "${1}" "${2}"
}

for JOB_ID in "${1}"
do
	echo "Now processing job: ${JOB_ID}"
	if [ ${JOB_ID} = "BACKUP-LOCAL" ]
	then
		echo "backing up docs and such.."		
		LOCAL_TARGET="${LOCAL_BACKUP_DRIVE}/Backup/Backup/Private/Local Backup"
		mkdir -p "${LOCAL_TARGET}"				
		copy_local_backup_folder "/cygdrive/c/Users/jason/Application Data/Mozilla/Firefox" "${LOCAL_TARGET}/firefox"
		copy_local_backup_folder "/cygdrive/c/Users/jason/Application Data/Thunderbird" "${LOCAL_TARGET}/thunderbird"
		copy_local_backup_folder "/cygdrive/c/Users/jason/Documents" "${LOCAL_TARGET}/Documents"
		copy_local_backup_folder "/cygdrive/c/scripts" "${LOCAL_TARGET}/scripts"
		chmod -R 777 "${LOCAL_TARGET}"
	elif [ ${JOB_ID} = "BACKUP-SYNCH-REMOTE" ]
	then
		echo "copying local backup to blunx"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Backup/" ${BLUNX_INFO}:/Users/jason/external/rsync/jason/Backup
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Backup To Burn/" "${BLUNX_INFO}:/Users/jason/external/rsync/jason/Backup\ To\ Burn/"
		echo "copying blunx files to local disk"
		mkdir -p "${LOCAL_BACKUP_DRIVE}/Backup/Blunx Backup"
		myrsync.sh ${BLUNX_INFO}:~/external/rsync/blunx/ "${LOCAL_BACKUP_DRIVE}/Backup/Blunx Backup/"
	elif [ ${JOB_ID} = "MOVIES" ]
	then
		echo "copying movies to local disk"
		mkdir -p ${LOCAL_ARCHIVE_DRIVE}/movies
		myrsync.sh ${BLUNX_INFO}:~/external/media/movies/ ${LOCAL_ARCHIVE_DRIVE}/movies/
	elif [ ${JOB_ID} = "MEDIA-LOCAL" ]
	then
		echo "copying media from boot drive to local disk"
		mkdir -p "${LOCAL_BACKUP_DRIVE}/Backup/Media Backup"
		myrsync.sh "${MEDIA_SOURCE}" "${LOCAL_BACKUP_DRIVE}/Backup/Media Backup/"
	elif [ ${JOB_ID} = "MEDIA-BLUNX" ]
	then
		echo "copying media from boot drive to blunx"
		myrsync.sh "${MEDIA_SOURCE}" ${BLUNX_INFO}:~/external/rsync/media/
	elif [ ${JOB_ID} = "USB-1TB" ]
	then
		echo "copying archive & backup to USB 1TB"
		mkdir -p "${USB_DRIVE}/Backup"
		myrsync.sh "${LOCAL_ARCHIVE_DRIVE}/Backup/" "${USB_DRIVE}/Backup/"
		mkdir -p "${USB_DRIVE}/Archive"
		myrsync.sh "${LOCAL_ARCHIVE_DRIVE}/Archive/" "${USB_DRIVE}/Archive/"
	elif [ ${JOB_ID} = "USB-300GB" ]
	then
		echo "copying stuff to USB 300GB"
		USB_DRIVE=/cygdrive/g
		mkdir -p "${USB_DRIVE}/Archive/My Archive"
		myrsync.sh "${LOCAL_ARCHIVE_DRIVE}/Archive/My Archive/" "${USB_DRIVE}/Archive/My Archive/"
	elif [ ${JOB_ID} = "BACKUP-E-TO-F" ]
	then
		echo "copying backup stuff from e to f"
		mkdir -p "${LOCAL_ARCHIVE_DRIVE}/Backup/Backup"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Backup/" "${LOCAL_ARCHIVE_DRIVE}/Backup/Backup/"
		mkdir -p "${LOCAL_ARCHIVE_DRIVE}/Backup/Backup To Burn"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Backup To Burn/" "${LOCAL_ARCHIVE_DRIVE}/Backup/Backup To Burn/"
		mkdir -p "${LOCAL_ARCHIVE_DRIVE}/Backup/Blunx Backup"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Blunx Backup/" "${LOCAL_ARCHIVE_DRIVE}/Backup/Blunx Backup/"
		mkdir -p "${LOCAL_ARCHIVE_DRIVE}/Backup/Media Backup"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Backup/Media Backup/" "${LOCAL_ARCHIVE_DRIVE}/Backup/Media Backup/"
	elif [ ${JOB_ID} = "ARCHIVE-E-TO-F" ]
	then
		echo "copying archive stuff from e to f"
		mkdir -p "${LOCAL_ARCHIVE_DRIVE}/Archive"
		myrsync.sh "${LOCAL_BACKUP_DRIVE}/Archive/" "${LOCAL_ARCHIVE_DRIVE}/Archive/"
	else 
		echo "What? don't know how to process this job: ${JOB_ID}"
	fi

done