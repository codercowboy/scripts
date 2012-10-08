#!/bin/bash

# for instructions, copyright info, and contact info, check out the readme.md file:
# https://github.com/codercowboy/scripts

SECONDS_TO_WAIT=600

BASE_PATH="/cygdrive/c/Program Files/Diablo II/save"

cd "$BASE_PATH"

while [ 1 ]
do
	DATE=`date +%Y%m%d-%H%M%S`
	ZIP_FILE_NAME="$BASE_PATH/diablo2.backup.$DATE.zip"
	echo "Backing up current save info to: $ZIP_FILE_NAME"
	zip "$ZIP_FILE_NAME" *.* -x *.zip
	echo "Sleeping for $SECONDS_TO_WAIT seconds.."
	sleep $SECONDS_TO_WAIT
	
done
