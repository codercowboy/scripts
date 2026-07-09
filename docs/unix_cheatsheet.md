here are a bunch of unix commands that may be of interest to you
some of them are builtins that just exist in bash and arent actual external
binary executable files, and some are binaries that may or may not exist on your flavor of unix

excellent reference for all sorts of unix tools: https://ss64.com/bash/ulimit.html
FIXME: note about homebrew

cd - change directory
Note: also look into "relative path", "absolute path"
Note: 'cd -' switches to the last directory we changed from with the last 'cd' statement
Note: '~' or ${HOME} is your home directory, 'cd ~' will change your terminal to your home dir

ls - list files and details such as sizes and permissions about them
Note: 'ls -alh' will show dot files and print file sizes in human-readable form

find - another tool to list files, this just prints names of files, and works recursively
Note: 


FIXME: explain the rest of these:
/dev/null and random etc
[ File system (Advanced) ]

apfs_hfs_convert
apfs_unlockfv
fsck_apfs
fsck_cs
fsck_exfat
fsck_hfs
fsck_msdos
fsck_udf
fstyp
fstyp_hfs
fstyp_msdos
fstyp_ntfs
fstyp_udf
mount
mount_9p
mount_acfs
mount_afp
mount_cddafs
mount_devfs
mount_exfat
mount_fdesc
mount_ftp
mount_msdos
mount_nfs
mount_ntfs
mount_smbfs
mount_tmpfs
mount_webdav
newfs_apfs
newfs_exfat
newfs_hfs
newfs_msdos
newfs_udf
umount
hdiutil
tmutil
df
du
dd
basename
dirname
fdupes
disklabel
readlink
stat



[ Archiving / Compression / Hashing ]
7z
base64
zip
tar
unrar
unzip
cksum
shasum
md5sum
rar


[Text Utils]
awk
cat 
diff
egrep
emacs
fgrep
grep
nano
less
head
more
tab2space
tail
sed
sort
split
vi
uniq
expand
paste
printf
cut
wc

[Development tools]
g++
make
gcc
binhex
atos
git
jar
java
javac
jconsole
jvisualvm
keytool
node
npm
perl
php
python
python3
ruby
expect
sqlite3
svn
strings
osascript
ulimit


[Network Tools]
curl
host
hostinfo
hostname
ifconfig
mail
nslookup
scp
sftp
wget
ping
ssh
rsync
dig

[Process / Environment Tools]
alias
bg
crontab
env
eval
exec
exit
kill
killall
halt
launchctl
launchd
nice
pkill
ps
reboot
screen
set 
setenv
unset
unsetenv
uptime
shutdown
sleep
suspend
top
export
unalias
defaults
wait
uname

[Auth and Auth]
su
sudo
chgrp
chmod
chpass
login
logout
users
who
whoami
whois
passwd
last
umask

[ Basic File System Tools]

cp
file
ln
rm
rmdir
pwd
mkdir
mktemp
mv
open
touch
type
shred

[ Shell Builtins And Misc ]
bash / csh / zsh / sh
clear
date
echo
getopt / getopts
expr
read
seq
tee
xargs
test
false
true
yes


[Help]
whatis
whereis
which
man

[Misc Tools]
bc
brew
imagemagick
jhead
openssl
say

[Unsorted]

!!  Run the last command again
!123
&   Start a new process in the background
alias   Create an alias •
alloc   List used and free memory
at  Schedule a command to run once at a particular time
automator   Run an Automator workflow
bless   Set volume bootability and startup disk options
bzip2   Compress or decompress files
caffeinate  Prevent the system from sleeping
cal Display a calendar
chgrp   Change group ownership
chmod   Change access permissions
chown   Change file owner and group
chroot  Run a command with a different root directory
cksum   Print CRC checksum and byte counts
createhomedir   Create and populate home directories on the local computer
cron    Daemon to execute scheduled commands
crontab Schedule a command to run at a later date/time
ddrescue    Data recovery tool
dirs    Display list of remembered directories •
diskutil    Disk utilities - Format, Verify, Repair
dot_clean   Remove dot-underscore files
eject   Eject removable media
fold    Wrap text to fit a specified width
format  Format disks or tapes
free    Display memory usage
fsck    File system consistency check and repair
fsck    Filesystem consistency check and repair
ftp File Transfer Protocol
ftp Internet file transfer program
function    Define Function Macros
fuser   Identify/kill the process that is accessing a file
groupadd    Add a user security group
groupdel    Delete a group
groupmod    Modify a group
groups  Print group names a user is in
groups  Print group names a user is in
halt    Stop and restart the operating system
hash    Remember the full pathname of a name argument
hdiutil Manipulate iso disk images
head    Display the first lines of a file
history Command History •
id  Print user and group names/id's
ifdown  Stop a network interface
ifup    Start a network interface up
iostat  Report CPU and i/o statistics
join    Join lines on a common field
link    Create a link to a file
ln  Create a symbolic link to a file
locate  Find files
logname Print current login name
logout  Exit a login shell •
look    Display lines beginning with a given string
lsof    List open files
mapfile Read lines from standard input into an indexed array variable •
mdfind  Spotlight search
mkfile  Make a file
mkisofs Create a hybrid ISO9660/JOLIET/HFS filesystem
mktemp  Make a temporary file
most    Browse or page through a text file
msgs    System messages
nc/netcat   Read and write data across networks
netstat Show network status
nslookup    Query Internet name servers interactively
ntfs.util   NTFS file system utility
open    Open a file/folder/URL/Application
osacompile  Compile Applescript
pbcopy  Copy data to the clipboard
pbpaste Paste data from the Clipboard
pdisk   Apple partition table editor
pushd   Save and then change the current directory
ram ram disk device
renice  Alter priority of running processes
screencapture   Capture screen image to file or disk
serverinfo  Server information
set -X
sharing Create share points for afp, ftp and smb services
shuf    Generate random permutations
softwareupdate  System software update tool
source  Execute commands from a file •
split   Split a file into fixed-size pieces
srm Securely remove files or directories
stat    Display the status of a file
stop    Stop a job or process
sum Print a checksum for a file
tab2space   Expand tabs and ensure consistent cr/lf line endings
tail    Output the last part of files
textutil    Manipulate text files in various formats (Doc,html,rtf)
time    Measure Program running time
timeout Run a command with a time limit
times   User and system times
touch   Change file timestamps
tr  Translate, squeeze, and/or delete characters
traceroute  Trace Route to Host
traceroute6 Trace IPv6 Route to Host
tty Print filename of terminal on stdin
unexpand    Convert spaces to tabs
unix2dos    UNIX to Windows or MAC text file format converter
useradd Create new user account
userdel Delete a user account
usermod Modify user account
users   List users currently logged in
uudecode    Decode a file created by uuencode
uuencode    Encode a binary file
uuidgen Generate a Unique ID (UUID/GUID)
w   Show who is logged on and what they are doing
wall    Write a message to users
watch   Execute/display a program periodically
write   Send a message to another user
youtube-dl  Download video