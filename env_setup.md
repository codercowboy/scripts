JASON'S SYSTEM SETUP CHEAT SHEET
================================

This is Jason's reminder list of setup steps when setting up a new OSX system.

REINSTALL PREP
=============
  * backup "sent" email to server
  * backup keychain items
  * backup voice memos
  * backup messages
  * backup passwords from lastpass
  * backup bookmarks
  * backup screenshots
  * backup random stuff in dot folders under home folder
  * other stuff backup scripts get such as voice memos, "add to itunes" in Pictures

INITIAL SETUP
=============

  * Backup old time machine disk
  * Wipe hard drive, and turn disk encryption on
  * Install OS 
  * Install all system updates
  * OS Settings Changes:
    * Set time machine backup disk
    * Remove external drives from time machine backup
    * Disable local time machine snapshots with:
      * sudo tmutil disablelocal
    * Disable spotlight and siri
    * Add external hard drives to spotlight ignore
    * Set Energy Settings as appropriate
    * Enable screen sharing, remote access, and file sharing
    * click "allow full disk access" in remote login sharing "i" info icon panel
    * Fix mouse scroll direction
    * Fix dock location
    * Add internet accounts for mail/calendars/contacts
    * Turn off bluetooth
    * Add guest account
    * Install printer
    * Fine tune notifications
    * Add common apps to stick on dock
    * Enable hidden files in finder with:
      * defaults write com.apple.finder AppleShowAllFiles YES
    * Check File Sharing Permissions (especially change "Everyone" from "Read/Write" to "No Access")
    * Rename computer in "Sharing" panel
    * Enable file sharing.
    * Add VPN settings
    * Change shell to bash in terminal: chsh -s /bin/bash
    * Disable "force click" under "touch pad -> point and click"
    * enable full disk access to terminal:
      * System prefs -> Security and Privacy -> Privacy Tab -> Full Disk Access -> Add Terminal
      * https://apple.stackexchange.com/questions/341959/how-do-programs-access-library-mail-under-osx-10-14-mojave
  * Install JDK, Eclipse, Dev Tools
  * Setup backup directories 
    * SERVER: ln -s /Volumes/Macintosh\ HD2 /external
  * Install Xcode, then homebrew, then these: rclone, wget, coreutils (and others from the brewlist in backup)
  * Open messages and ensure it can get msgs from iphone, needs to be opened once for this to start
  * Soft link md5sum with:
    * sudo ln -s /usr/local/opt/coreutils/libexec/gnubin/md5sum /usr/local/bin/md5sum
  * Restore system files (jason ~/setupenv.sh, etc/hosts, etc/profile, etc/paths, ssh keys, and so on)
  * Soft link scripts:
  	* LAPTOP: sudo ln -s /Users/jason/Documents/code/scripts /scripts
  	* SERVER: ln -s /Volumes/Macintosh\ HD2/misc/scripts /scripts
  * Install applications listed below
  * Disable wifi if needed
  * Fix ssh keys
  * Install open folder in stext finder plugin. 
    * copy to ~/Library/Services (from laptop backup "automator_services.zip" file in backup/misc).
    * System Preferences > Keyboard > Shortcuts > Services -> Enable "Open in Sublime Text"
  * Install open folder in terminal.
    * http://lifehacker.com/launch-an-os-x-terminal-window-from-a-specific-folder-1466745514
    * System Preferences > Keyboard > Shortcuts > Services -> "New Terminal at Folder"

VERIFICATION
============
  * Ensure backup is working well
  * Ensure time machine works

APPLICATIONS
============
  * 4K Video Downloader
  * 4K YouTube to MP3
  * Acorn (from store)
  * AdvancedRestClient
  * Amazon Drive
  * Android File Transfer
  * Audacity
  * Blackhole sound driver
  * Blackmagic Disk Speed Test
  * BookWright
  * CrossOver
  * Cyberduck
  * Disk Cartography
  * Disk Inventory X
  * Display Menu (from store)
  * Dolphin
  * DosBox
  * Dropbox
  * FileZilla Pro
  * FileZilla
  * Friendly Streaming
  * FTP Server (from store)
  * GarageBand
  * Giphy Capture
  * Google Chrome
  * HandBrake
  * iMovie
  * Keynote
  * Kindle
  * LastPass
  * MakeMKV
  * Messenger
  * Microsoft Remote Desktop
  * Minecraft  
  * MusicBrainz Picard
  * Numbers
  * OpenEMU  
  * Pages
  * Pixlr
  * RealVNC
  * Skype
  * Slack
  * SmartSVN
  * Sourcetree
  * Spotify
  * Steam
  * Sublime Text
  * The Unarchiver (from store)
  * Thunderbird
  * Transmission
  * Utilities
  * VirtualBox
  * VLC
  * VNC Viewer
  * What
  * WineBottler
  * xACT
  * XAMPP
  * Xcode
  * XLD
  * XQuartz
  * Zoom

OLD BACKUP CONFIG FILES
=======================

**how to load into plist into launchd:**
 * http://superuser.com/questions/36087/how-do-i-run-a-launchd-command-as-root
 * sudo chmod 755 /System/Library/LaunchDaemons/serverbackup.plist
 * sudo launchctl load -w /System/Library/LaunchDaemons/serverbackup.plist

**root cron job to run reports at 8:30pm:**)
 * http://superuser.com/questions/391204/what-is-the-difference-between-periodic-and-cron-on-os-x
 * file tabs are stored in: /usr/lib/cron/tabs
 * Run sudo crontab -e and add these lines:

		MAILTO=jason@onejasonforsale.com
		30 20 * * * bash /scripts/to_sales_reports/fetch_reports.sh

**/System/Library/LaunchDaemons/serverbackup.plist file contents:**

		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
		"http://www.apple.
		com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
		<dict>  
			<key>Label</key><string>serverbackup</string>
			<key>ProgramArguments</key>
			<array> 
				<string>/archive/scripts/serverbackup.sh</string>
			</array>
			<key>WorkingDirectory</key><string>/archive/scripts</string>
			<key>EnvironmentVariables</key>
			<dict>
				<key>PATH</key>
				<string>/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/archive/scripts</string>
			</dict>
			<key>LowPriorityIO</key><true/>
			<key>Nice</key><integer>1</integer>
			<key>StartCalendarInterval</key>
			<dict>  
				<key>Hour</key><integer>4</integer>
				<key>Minute</key><integer>10</integer>
			</dict>
			<key>StandardOutPath</key><string>/var/log/serverbackup.log</string>
			<key>StandardErrorPath</key><string>/var/log/serverbackup.log</string>
		</dict>
		</plist>

**autodiskmount.plist file contents:**

		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" 
		   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
			<dict>
			    <key>AutomountDisksWithoutUserLogin</key><true/>
			</dict>
		</plist>

**/etc/daily.local file contents:**

		#!/bin/bash
		/scripts/systembackup.sh 2>&1 | tee -a /var/log/systembackup.log

**/etc/weekly.local file contents:**

		#!/bin/bash
		/archive/scripts/osxrotatelogs.sh /var/log /archive/logs/locallogs/