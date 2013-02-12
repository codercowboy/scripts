Coder Cowboy Scripts
====================

Various bash scripts to help you on your way.

* written by Jason Baker ([jason@onejasonforsale.com](mailto:jason@onejasonforsale.com))
* on github: [https://github.com/codercowboy/scripts](https://github.com/codercowboy/scripts)
* more info: [http://www.codercowboy.com](http://www.codercowboy.com)

Basic Instructions
==================

Bash is a scripting language that's provided with linux distributions. It's a lot like batch scripts on DOS/Windows. Bash is open source and free. That means you already have it on your linux or OSX box, and you can easily install it on your windows machine using [cygwin](http://www.cygwin.com).

If you're interested in learning bash scripting, here are two resources to check out, the first one is especially important to check out:

* [How to excel at bash scripting](http://www.codercowboy.com/2012/07/07/how-to-excel-at-bash-scripting/)
* [Coder Cowboy Programming Resources](http://www.codercowboy.com/programming-stuff-links-books/) - check out the "Unix Scripting" sectionmarkd

What the scripts do
===================

* bad2x.sh - list @2x image files with odd dimensions
* diablo2-backup - a set of scripts to backup diablo2 character saves on windows, while you run it.
* dircomplete.sh - adds a trailing slash "/" to passed in path if it does not already end in "/"
* execeachline.sh - executes given script on each line of a file
* filesize.sh - file size display script
* filesizetest.sh - compare file sizes script
* fix2x.sh - generate @2x and non-@2x image assets for IOS projects
* freespace.sh - disk free space display script
* linecounter.sh - source code line counting script
* listcopy.sh - copy files or folders specified in a text file
* maillog.sh - a script to mail a log to yourself using ssmpt
* md5tool.sh - md5 digest creation & validation script
* myrsync.sh - a quick wrapper for rsync with sane options on by default
* osxrotatelogs.sh - archive a gzipped timestamped version of logs
* processdiff.sh - print a user friendly version of diff's output
* renameit.sh - rename image files w/ a timestamp based on last modified time
* rsyncjob.sh - personal rsync job script
* snapshot.sh creates and removes dated snapshot directories

Notes
=====

Maybe someday I'll consolidate several of the helpful-almost-one-liner scripts into a nice utility script you can include in your .bash_profile.

If you have any questions, comments, kudos, criticisms about any of the scripts, e-mail me. 

Licensing
=========

All scripts are licensed with the [Apache license](http://en.wikipedia.org/wiki/Apache_license), which is a great license because, essentially it:
* a) covers liability - my code should work, but I'm not liable if you do something stupid with it
* b) allows you to copy, fork, and use the code, even commercially
* c) is [non-viral](http://en.wikipedia.org/wiki/Viral_license), that is, your derivative code doesn't *have to be* open source to use it

Other great licensing options for your own code: the BSD License, or the MIT License.

Here's the license:

Copyright (c) 2012, Coder Cowboy, LLC. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* 1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
  
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied.