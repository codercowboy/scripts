/*
	TODO:

	* Make create print out md5 of checksum file like md5tool.sh does
	* Add verbose mode 
	* verifyall should aggregate stats	
	* add tests, need to test all error case paths ie removed, moved, added
	* add copyright license notice
	* add usage

	Future Features:

	* Add update checksum mode.
	* Add joinall etc from old script
*/

'use strict';

const fs = require('fs');
const path = require('path');
const cc = require('../cclib/cclib.js');

const { MD5Result, MD5ResultMap, MD5ResultDiff, MD5Lib } = require("./md5lib.js");

var md5Lib = new MD5Lib();

var cwd = null;
var mode = null;
var testMode = false;

function processArgs() {
	if (process.argv.length < 3) {
		cc.log.error("Not enough args.");
		cc.exit(1);
	}

	for (var arg of process.argv.values()) {
		arg = arg.toLowerCase();
		if ("test" == arg) {
			cc.log.log("Test mode enabled.");
			testMode = true;
			cc.log.debugMode = true;
		} else if ("debug" == arg) {
			cc.log.log("Debug mode enabled.");
			cc.log.debugMode = true;
		} else if ("create" == arg || "createforeach" == arg
			|| "verify" == arg || "verifyall" == arg) {
			mode = arg;
		}
	}	

	if (mode == null) {
		cc.log.error("Execution mode was not specified.");
		cc.exit(1);
	}

	cc.log.debug("Mode: " + arg);

	cwd = process.argv[process.argv.length - 1];

	if (!cc.fileutil.isDir(cwd)) {
		cc.log.error("Directory does not exist: " + cwd);
		cc.exit(1);
	}

	cwd = fs.realpathSync(cwd);
	cc.log.log("Working Directory: " + cwd);
}

function createChecksumForEach(directory) {
	var totalSize = 0;
	var fileCount = 0;
	var checksumFileCount = 0;
	for (var file of fs.readdirSync(directory)) {
		var filePath = directory + path.sep + file;
		if (cc.fileutil.isDir(filePath)) {
			var result = md5Lib.createChecksumFile(filePath);
			totalSize += result.totalSize;
			fileCount += result.fileCount;
			checksumFileCount += 1;
		}
	}
	cc.log.log("Created " + checksumFileCount + " " + CHECKSUM_FILE_NAME + " files. Indexed " 
		+ fileCount.toLocaleString() + " files, " + cc.stringutil.formatFileSizePretty(totalSize) + ".");
}

function verifyAllChecksums(directory) {
	for (var file of cc.fileutil.listFiles(directory)) {
		if (file.indexOf(CHECKSUM_FILE_NAME) != -1) {
			var fullFilePath = directory + path.sep + file;
			var checksumDirectory = path.dirname(fullFilePath);
			md5Lib.verifyChecksums(checksumDirectory);
		}
	}
}

async function main() {
	var startTime = Date.now();
	processArgs();
	if (mode == "create") {
		md5Lib.createChecksumFile(cwd);
	} else if (mode == "createforeach") {
		createChecksumForEach(cwd);
	} else if (mode == "verify") {
		md5Lib.verifyChecksums(cwd);
	} else if (mode == "verifyall") {
		verifyAllChecksums(cwd);
	}	
	var timeElapsed = Date.now() - startTime;
	cc.log.log("Execution Time: " + cc.stringutil.formatTimeHMSPretty(timeElapsed));
	
	cc.exit(0);
}

main();
