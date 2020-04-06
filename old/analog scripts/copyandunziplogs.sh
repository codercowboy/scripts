#!/bin/bash

#first arg is directory to copy .gz files from
#second arg is directory to copy .gz files to, unzip gz files, and delete gz files
function copy_and_unzip_logs
{
    echo "now handling: $2"
    
    #the directory to copy logs from
    FROM_DIR="/archive/logs/$1"
    
    #make sure we own, and can read/write the files
    chown -R root "$FROM_DIR"
    chgrp -R wheel "$FROM_DIR"
    chmod -R 770 "$FROM_DIR"
    
    #the directory to copy logs to
    TO_DIR="/archive/logs/$2/"

    #copy all of the *.gz files from here to there
    find "$FROM_DIR/" -name 'access*.gz' -exec cp {} "$TO_DIR"  \;
    
    #unzip all of the *.gz files
    find "$TO_DIR" -name '*.gz' -exec gunzip -f {} \; 
    
    #delete all of the *.gz in the destination directory
    find "$TO_DIR" -name '*.gz' -exec rm {} \;
}

echo "[copy and unzip logs]"

echo " copying remote logs.."
copy_and_unzip_logs "remotelogs/onejasonforsale.com/http" "unzipped/ojfs"
copy_and_unzip_logs "remotelogs/anesotericvision.com/http" "unzipped/esoteric"
copy_and_unzip_logs "remotelogs/experimentalfutility.com/http" "unzipped/futility"
copy_and_unzip_logs "remotelogs/worldsworstsoftware.com/http" "unzipped/wws"
copy_and_unzip_logs "remotelogs/amandaandjasonrule.com/http" "unzipped/aajr"
copy_and_unzip_logs "remotelogs/theantipatterns.com/http" "unzipped/antipatterns"
copy_and_unzip_logs "remotelogs/kunosdream.com/http" "unzipped/kuno"
copy_and_unzip_logs "remotelogs/worldsworstphotography.com/http" "unzipped/wwp"


echo " copying local logs.."
copy_and_unzip_logs "locallogs" "unzipped/blunx"

#echo " copying old logs.."
#copy_and_unzip_logs "oldlogs/ojfs" "unzipped/ojfs"
#copy_and_unzip_logs "oldlogs/esoteric" "unzipped/esoteric"
#copy_and_unzip_logs "oldlogs/futility" "unzipped/futility"
#copy_and_unzip_logs "oldlogs/antipatterns" "unzipped/antipatterns"
#copy_and_unzip_logs "oldlogs/wws" "unzipped/wws"
#copy_and_unzip_logs "oldlogs/aajr" "unzipped/aajr"
#copy_and_unzip_logs "oldlogs/blunx" "unzipped/blunx"
#copy_and_unzip_logs "oldlogs/kuno" "unzipped/kuno"
#copy_and_unzip_logs "oldlogs/wwp" "unzipped/wwp"

