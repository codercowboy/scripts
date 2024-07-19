#!/bin/bash

if [ "`type -t my_rsync_checksum`" = "function" ]; then
	echo "Skipping import functions from lib_rsync.sh, they're already sourced in this shell"
	return 0
fi

###############
# RSYNC STUFF #
###############

# export these functions so child processes, such as scripts running, can see them
# https://stackoverflow.com/questions/33921371/command-not-found-when-running-defined-function-in-script-file

# rsync arguments 
#  -v = verbose
#  -r = recursive 
#  -t = preserve times
#  -W = transfer whole file 
#  --del = delete non existing files
#  -stats = print stats at end
#  --progress = show progress while transfering
#  --chmod = change perms on target
#  -c = skip based on checksum rather than mod-time/size 
#  --size-only = skip only based on size changes, not checksum or modtime
#  --modify-window = allow a mod time drive of N seconds, useful for fat32 with less precise mod-time storage
#  -i = show the reason rsync is transfering the file
#  -n = dry run (test mode)

# itemized changes output example:
# >f..t.... file.txt
# c = checksum differs, s = size differs, t = mod time differs ,p = perms differ
# o = owner differs, g = group differs

function my_rsync_checksum { 	
	rsync -cvrthW --del --stats --progress --chmod=u=rwx "${@}" 
}
export -f my_rsync_checksum

function my_rsync_checksum_test { 	
	rsync -incvrthW --del --stats --progress --chmod=u=rwx "${@}" 
}
export -f my_rsync_checksum_test

function my_rsync() { 	
	rsync -vrthW --del --stats --progress --chmod=u=rwx "${@}" 
	echo ""
	echo "WARNING: my_rsync only skips files based on size / mod time differences!"
	echo "  for a more secure checksum-based transfer, use my_rsync_checksum"
}
export -f my_rsync

function my_rsync_test {	
	rsync -invrthW --del --stats --progress --chmod=u=rwx "${@}" 
	echo ""
	echo "WARNING: my_rsync only skips files based on size / mod time differences!"
	echo "  for a more secure checksum-based transfer, use my_rsync_checksum"
}
export -f my_rsync_test

# fat32's modtime isn't as precise as other file systems, and there are various other problems
# such as the fat32 not storing timezones, so during DST the file's mod time looks to be off by one hour
# for this reason, on the fat32 alias we're using the --size-only command that ignores mod times
# source: https://stackoverflow.com/questions/15640570/rsync-and-backup-and-changing-timezone
# source: https://serverfault.com/questions/470046/rsync-from-linux-host-to-fat32
# fat32's 

function my_rsync_fat32 {	
	rsync -rv --size-only --del --stats --progress "${@}" 
	echo ""
	echo "WARNING: my_rsync_fat32 only skips files based on size difference, not mod time!"
	echo "WARNING: my_rsync_fat32 does not preserve mod-times!"
}
export -f my_rsync_fat32

function my_rsync_fat32_test {
	rsync -inrv --size-only --del --stats --progress "${@}" 
	echo ""
	echo "WARNING: my_rsync_fat32 only skips files based on size difference, not mod time!"
	echo "WARNING: my_rsync_fat32 does not preserve mod-times!"
}
export -f my_rsync_fat32_test