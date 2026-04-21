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
  * Backup old time machine disk

INITIAL SETUP
=============
  * Wipe hard drive, and turn disk encryption on
  * Install OS 
  * Install all system updates
  * OS Settings Changes:
    * Settings -> Trackpad -> More Gestures tab -> turn everything off
    * Disable "force click" under "touch pad -> point and click"
    * Disable spotlight and siri and add external hard drives to spotlight ignore
    * Set Energy Settings as appropriate
    * Fix mouse scroll direction
    * Fix dock location
    * Add internet accounts for mail/calendars/contacts
    * Turn off bluetooth if needed
    * Disable wifi if needed
    * Add guest account
    * Install printer
    * Fine tune notifications
    * Add common apps to stick on dock
    * Enable hidden files in finder with: defaults write com.apple.finder AppleShowAllFiles YES
    * Add VPN settings
    * Show VPN in system bar: system settings -> menu bar -> check "VPN" box
    * Change shell to bash in terminal: chsh -s /bin/bash
  * Terminal Settings: 
    * terminal settings menu -> first tab ('general') -> top 'on startup open' -> new window with profile -> change to "Basic"
    * terminal settings menu -> second tab ('profiles') -> select 'Basic' top left column, then click 'Default' button at bottom of left column
    * System prefs -> Security and Privacy -> Privacy Tab -> Full Disk Access -> Add Terminal
  * File / Screen Sharing + Remote Login:
    * Rename computer in "Sharing" panel 
    * Enable screen sharing, remote access, and file sharing
    * Check File Sharing Permissions (especially change "Everyone" from "Read/Write" to "No Access") 
    * Click "allow full disk access" in remote login sharing "i" info icon panel
  * Open messages and ensure it can get msgs from iphone, needs to be opened once for this to start  
  * Restore system files from previous backup (jason ~/setupenv.sh, etc/hosts, etc/profile, etc/paths, ssh keys, and so on)
  * Install applications listed in apps list from previous backup
  * Setup garageband podcast audio routing (blackhole sound driver + aggregate device)
  * Developer stuff
    * Install JDK, Eclipse, Dev Tools, Xcode, Brew, SourceTree
    * Install brew programs from backup list
    * Soft link md5sum sudo ln -s /opt/homebrew/bin/gmd5sum /opt/homebrew/bin/md5sum
    * After running sourctree first time, softlink sourcetree bin: sudo ln -s "/Applications/Sourcetree.app/Contents/Resources/stree" /usr/local/bin/
    * After first run, sourcetree will try to put blank user name/email fields at end of ~/.gitconfig, remove these
    * Fix ssh keys
  * MacBox setup
    * install macbox, open it, main window bottom left corner click 'install x86box.app', then import VM (look for MacBoxFiles dir inside vm folder)
  * Install open folder in stext finder plugin. 
    * copy to ~/Library/Services (from laptop backup "automator_services.zip" file in backup/misc).
    * System Preferences > Keyboard > Shortcuts > Services -> Expand Files and folder tree -> Enable "Open in Sublime Text"
  * Install open folder in terminal.
    * http://lifehacker.com/launch-an-os-x-terminal-window-from-a-specific-folder-1466745514
    * System Preferences > Keyboard > Shortcuts > Services -> "New Terminal at Folder"
  * Setup time machine:
    * https://support.apple.com/en-ca/guide/mac-help/mchl31533145/mac
    * Target mac: 
      * Settings -> Sharing, Enable File Sharing.
      * Still in file sharing, click info, then options, enable "Share files and folders using SMB"
      * Add target folder to bottom of Shared Folder list. 
      * Ctrl+click added folder in shared folder list, click advanced options, enable "Share as a Time Machine backup destination", optionally enable "limt backups to" size.
    * Source mac:
      * Set time machine backup disk to network drive on target mac
      * Remove external drives from time machine backup
  * Prevent mac mini from falling asleep:
    * System Settings -> Displays -> Advanced -> Battery & Energy -> Prevent automatic sleeping on power adapter when the display is off
    * System Settings -> Lock Screen -> Turn display off when inactive -> Never
    * apple logo -> about this mac -> more info -> power - disable any automatic sleep item
    * More: https://www.reddit.com/r/MacOS/comments/141cjzs/mac_mini_keeps_going_to_sleep/

VERIFICATION
============
  * Ensure backup is working well
  * Ensure time machine works

Old Stuff
=========

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