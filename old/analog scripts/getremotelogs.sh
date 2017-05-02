#!/bin/bash
REMOTE_PATH="${WEBHOST_USER}:${WEBHOST_HOST}:~/logs/"
LOCAL_PATH="/archive/logs/remotelogs"
ARGS="-e ssh -alv --include '*.com/' --include '*.com/http' --include 'http*/'  --include '/**/**/*.gz' --exclude '*'"
eval "rsync $ARGS \"$REMOTE_PATH\" \"$LOCAL_PATH\""

echo "copying logs to archived area.."
cp -R /archive/logs/remotelogs/* /archive/logs/archiveremotelogs/
