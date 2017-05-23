install .bash_profile in users/jason


#make root .bashrc point to jason .bash_profile:

(as root): ln -s /Users/jason/.bash_profile /var/root/.bashrc

# fix md5sum
# after 'brew install coreutils'
# sudo ln -s /usr/local/opt/coreutils/libexec/gnubin/md5sum /usr/local/bin/md5sum

# disable time machine local backups
# http://osxdaily.com/2011/09/28/disable-time-machine-local-backups-in-mac-os-x-lion/
# sudo tmutil disablelocal

#runs daily backup
/etc/daily.local

#backup thing
/System/Library/LaunchDaemons/blunx.backup.plist
#info on how to load into launchd:
# http://superuser.com/questions/36087/how-do-i-run-a-launchd-command-as-root
# chmod 755 /System/Library/LaunchDaemons/blunx.backup.plist
# sudo launchctl load -w /System/Library/LaunchDaemons/blunx.backup.plist

#root cron job to run reports at 8:30pm
# from http://superuser.com/questions/391204/what-is-the-difference-between-periodic-and-cron-on-os-x
# /usr/lib/cron/tabs
# Run sudo crontab -e and add these lines:
# MAILTO=jason@onejasonforsale.com
# 30 20 * * * bash /scripts/to_sales_reports/fetch_reports.sh

install brew
with brew install wget, md5sum (core-utils), ln -s md5sum and so on
on server ln -s external and scripts
put ssh keys in place
update bash profile to link to scripts bash_profile.sh

 16M	./Acorn.app
6.1M	./Android File Transfer.app
 75M	./Audacity
 17M	./Blackmagic Disk Speed Test.app
255M	./BookWright.app
143M	./Cyberduck.app
9.4M	./Disk Inventory X.app
174M	./Dropbox.app
410M	./Google Chrome.app
 25M	./HandBrake.app
5.9M	./ImageOptim.app
114M	./MakeMKV.app
332M	./Minecraft.app
 91M	./Pixlr.app
107M	./SimCity 2000.app
121M	./Skype.app
167M	./SmartSVN 9.app
124M	./SourceTree.app
161M	./Spotify.app
675M	./Steam.app
 26M	./Sublime Text 2.app
4.4M	./The Unarchiver.app
168M	./Thunderbird.app
 11M	./Transmission.app
168M	./VirtualBox.app
109M	./VLC.app
790M	./XAMPP
9.2G	.
