Diablo 2 Backup Scripts
=======================

A few years back (2009?) my buddies and I hacked and slashed through Diablo 2 yet again. At the time we'd experience crashes every so often that'd leave our save-files corrupted and we'd lose characters we'd drained hours and hours of time into. 

This set of scripts automates backing up your character save files every so often while you're playing.

To use the scripts on your windows computer, do the following:

1) Download the scripts.
2) Put the scripts on your computer in the c:\scripts directory.
3) Install cygwin on your computer
4) Add c:\cygwin\bin to your computer's PATH variable in environment variables
5) Create a shortcut on your desktop to the c:\scripts\rundiablo2.bat file
6) Run diablo 2 by double clicking on that shortcut.

When the script runs it:
1) Opens the backup script in a command window (the black box window), which will auto-backup dated zip files every so often.
2) Run diablo 2 for you

Backed up character save files will be in dated zip files in this directory:

c:\Program Files\Diablo II\save\

If you have any trouble with the scripts, don't hesitate to e-mail me.

########################################################################
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   on github: https://github.com/codercowboy/scripts
#   more info: http://www.codercowboy.com
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