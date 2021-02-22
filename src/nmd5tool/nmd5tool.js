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

const CHECKSUM_FILE_NAME = "checksum.md5";

var cwd = null;
var mode = null;
var testMode = false;

function processArgs() {
	if (process.argv.length < 3) {
		cc.log.error("Not enough args.");
		cc.exit(1);
	}

	for (var arg of process.argv) {
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
			cc.log.debug("Mode: " + arg);
			mode = arg;
		}
	}

	if (mode == null) {
		cc.log.error("Execution mode was not specified.");
		cc.exit(1);
	}

	cwd = process.argv[process.argv.length - 1];

	if (!cc.fileutil.isDir(cwd)) {
		cc.log.error("Directory does not exist: " + cwd);
		cc.exit(1);
	}

	cwd = fs.realpathSync(cwd);
	cc.log.log("Working Directory: " + cwd);
}

class MD5Result {
	constructor(fileRelativePath, fullFilePath, checksum, source) {
		this.fileRelativePath = fileRelativePath;
		this.fullFilePath = fullFilePath;
		this.checksum = checksum;
		this.source = source;
		this.fileDetails = new Object();
		this.verifyStatus = new Object();
		if (cc.fileutil.isFile(fullFilePath)) {
			var stats = fs.statSync(fullFilePath);
			this.fileDetails.basename = path.basename(fullFilePath);
			this.fileDetails.size = stats.size;
			this.fileDetails.modTimeMs = stats.mtimeMs;
		}
	}
}

class MD5ResultDiff {
	constructor(oldResults, newResults) {
		this.errorsOccurred = false;
		this.counts = [];
		this.oldResults = oldResults;
		this.newResults = newResults;
		this.finishedResults = [];
		this.finishedResultsMap = [];
		
		var newMap = cc.collectionutil.mapBy(newResults, "fileRelativePath");
		var missingOldResults = [];		
		var addTime = new Date().toDateString();
		for (var oldResult of oldResults) {
			var newResult = newMap[oldResult.fileRelativePath];
			if (newResult == null) {
				missingOldResults.push(oldResult);
				continue;
			}			
			delete newMap[oldResult.fileRelativePath];
			if (oldResult.checksum == newResult.checksum) {
				this.addResult(oldResult, false, "Verified", null);
				continue;
			} else {
				cc.log.debugobj(oldResult, newResult);
				this.addResult(oldResult, true, "Failed", " (" + oldResult.checksum + " -> " + newResult.checksum + ")");
				continue;
			}
		}
		var leftoverNewFilesChecksumMap = cc.collectionutil.mapBy(newMap, "checksum");
		for (var oldResult of missingOldResults) {
			var newResult = leftoverNewFilesChecksumMap[oldResult.checksum];
			if (newResult == null) {
				this.addResult(oldResult, true, "Removed", null);
				continue;
			}
			delete leftoverNewFilesChecksumMap[oldResult.checksum];
			this.addResult(oldResult, true, "Moved", " -> " + newResult.fileRelativePath);
		}
		for (var newResult of leftoverNewFilesChecksumMap) {
			if (newResult == null) {
				continue;
			}
			this.addResult(newResult, true, "Added", "Added " + addTime);
		}

		this.printStatus();
	}

	printStatus() {
		for (var key of cc.collectionutil.getSortedKeys(this.finishedResultsMap)) {
			var results = this.finishedResultsMap[key]; 
			cc.log.log(key + " (" + results.length + " files):");
			var resultsMap = cc.collectionutil.mapBy(results, "fileRelativePath");
			for (var resultKey of cc.collectionutil.getSortedKeys(resultsMap)) {
				var result = resultsMap[resultKey];
				cc.log.log(result.fileRelativePath + " " + result.verifyStatus.description);
			}	
			cc.log.log("");		
		}

		cc.log.log("\nVerification Results");
		for (var countKey of cc.collectionutil.getSortedKeys(this.counts)) {
			cc.log.log("  " + countKey + ": " + this.counts[countKey]);
		}
		cc.log.log("  Final Status: " + (this.errorsOccurred ? "ERROR" : "SUCCESS") + "\n\n");
	}

	addResult(md5Result, isError, status, statusDesc) {
		statusDesc = status.toUpperCase() + ((statusDesc == null) ? "" :  " " + statusDesc);
		md5Result.verifyStatus.description = statusDesc;
		md5Result.verifyStatus.isError = isError;
		md5Result.verifyStatus.status = status.toUpperCase();
		this.incrementCount("Total Files");
		this.incrementCount(status);
		if (isError) {
			this.incrementCount("Total Errors");
			this.errorsOccurred = true;
		}
		this.finishedResults.push(md5Result);
		var key = status.toUpperCase();
		if (this.finishedResultsMap[key] == null) {
			this.finishedResultsMap[key] = [];
		}
		this.finishedResultsMap[key].push(md5Result);
	}
	
	incrementCount(countName) {
		if (this.counts[countName] == null) {
			this.counts[countName] = 0;
		}
		this.counts[countName] += 1;
	}

	getFilesWithStatus(status) {
		var results = [];
		for (var result of this.finishedResults) {
			if (status.verifyStatus.toLowerCase().indexOf(status) != -1) {
				results.push(result);
			}
		}
		return results;
	}

	getVerifiedFiles() { return this.getFilesWithStatus("VERIFIED"); }
}

function getChecksums(directory) {
	var result = [];
	for (var file of cc.fileutil.listFiles(directory)) {
		var fullFilePath = directory + path.sep + file;
		if (cc.fileutil.isDir(fullFilePath)) {
			cc.log.debug("+++ Skipping directory: " + file);
			continue;
		} else if (fullFilePath.indexOf(CHECKSUM_FILE_NAME) != -1) {
			cc.log.debug("+++ Skipping checksum file: " + file);
			continue;
		}
		cc.log.debug("+++ Processing File: " + file);
		var checksum = cc.fileutil.md5(fullFilePath);

		var md5Result = new MD5Result(file, fullFilePath, checksum, "file system");
		result.push(md5Result);
		cc.log.debug("Parsed md5 result.", md5Result);
		cc.log.debug("+++ Finished processing file: " + file);
		cc.log.debug("");
	}
	return result;
}

function readChecksumsFromFile(directory) {
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	cc.log.debug("+++ Reading checksum file: " + checksumFile);
	var fileContents = "" + fs.readFileSync(checksumFile);
	var result = [];
	var lastStatusLine = null;
	var currentResult = new MD5Result(null, null, null);
	var lineNumber = 0;
	for (var line of fileContents.split("\n")) {
		lineNumber += 1;
		cc.log.debug("Processing line #" + lineNumber + ": " + line);
		if (line.indexOf("# File: ") == 0) {
			//example line: # File: file.mobi :: Added Sat Apr 04 2020 # {"basename":"file.mobi","size":2265889,"modTimeMs":1585984751704}
			cc.log.debug("Found status line: " + line);
			lastStatusLine = line;
			continue;
		} else if (line.indexOf("#") == 0 || line.trim().length == 0) {
			lastStatusLine = null;
			cc.log.debug("Skipping line: '" + line + "'");
			continue;
		}
		// example line: 7f2501e1d8c37ad446be0fe0d612d240 *./file.mobi
		var spaceLocation = line.indexOf(" ");
		if (spaceLocation == -1) {
			error("Cannot parse line #" + lineNumber + ": " + line);
			lastStatusLine = null;
			continue;
		}
		var checksum = line.substr(0, spaceLocation);
		var fileRelativePath = line.substr(spaceLocation + 4);
		var fullFilePath = path.dirname(checksumFile) + path.sep + fileRelativePath;
		var md5Result = new MD5Result(fileRelativePath, fullFilePath, checksum, checksumFile);

		if (lastStatusLine != null) {
			var statusLocation = lastStatusLine.indexOf("::");
			var commentLocation = lastStatusLine.substr(2).indexOf("#");
			md5Result.status = lastStatusLine.substr(statusLocation + 3, commentLocation - statusLocation - 2);
			var json = lastStatusLine.substr(commentLocation + 3);
			cc.log.debugobj(json);
			md5Result.fileDetails = JSON.parse(json);
		}
		lastStatusLine = null;
		cc.log.debug("Parsed md5 result.", md5Result);
		result.push(md5Result);
	 }
	 cc.log.debug("+++ Finished reading checksum file: " + checksumFile);
	 return result;
}

function createChecksumFile(directory) {
	var startTime = Date.now()
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	process.stdout.write("Creating: " + checksumFile + " ");
	var md5Results = getChecksums(directory);
	var addTime = new Date().toDateString();
	var totalSize = 0;
	var fileContents = "";
	for (var result of md5Results) {
		var status = "";
		if (result.fileDetails != null) {
			status += "# File: " + result.fileDetails.basename 
			if (result.status == null) {
				result.status = "Added " + addTime;
			}
			status += " :: " + result.status;
			status += " # " + JSON.stringify(result.fileDetails) + "\n";
			totalSize += result.fileDetails.size;
		}
		status += result.checksum + " *./" + result.fileRelativePath;
		
		fileContents += status + "\n";
	}
	var timeElapsed = cc.stringutil.formatTimeHMSPretty(Date.now() - startTime);
	var message = "[" + md5Results.length + " files, " + cc.stringutil.formatFileSizePretty(totalSize) + ", " + timeElapsed + "]";
	fileContents += "# Created " + addTime + " " + message;
	process.stdout.write(message + "\n");
	if (cc.log.debugMode) {
		cc.log.debug("Checksum File Contents: \n" + fileContents + "\n\n");
	}
	fs.writeFileSync(checksumFile, fileContents);	
	return { totalSize:totalSize, fileCount:md5Results.length };
}

function createChecksumForEach(directory) {
	var totalSize = 0;
	var fileCount = 0;
	var checksumFileCount = 0;
	for (var file of fs.readdirSync(directory)) {
		var filePath = directory + path.sep + file;
		if (cc.fileutil.isDir(filePath)) {
			var result = createChecksumFile(filePath);
			totalSize += result.totalSize;
			fileCount += result.fileCount;
			checksumFileCount += 1;
		}
	}
	cc.log.log("Created " + checksumFileCount + " " + CHECKSUM_FILE_NAME + " files. Indexed " 
		+ fileCount.toLocaleString() + " files, " + cc.stringutil.formatFileSizePretty(totalSize) + ".");
}

function verifyChecksums(directory) {
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	if (!cc.fileutil.isFile(checksumFile)) {
		cc.log.error("Checksum file does not exist: " + checksumFile);
		cc.exit(1);
	}
	log("Verifying: " + checksumFile);
	var oldResults = readChecksumsFromFile(directory);
	debug("++ Checksumming files in directory: " + directory);
	var currentResults = getChecksums(directory);
	debug("++ Finished checksumming files in directory: " + directory);
	var diff = new MD5ResultDiff(oldResults, currentResults);
}

function verifyAllChecksums(directory) {
	for (var file of cc.fileutil.listFiles(directory)) {
		if (file.indexOf(CHECKSUM_FILE_NAME) != -1) {
			var fullFilePath = directory + path.sep + file;
			var checksumDirectory = path.dirname(fullFilePath);
			verifyChecksums(checksumDirectory);
		}
	}
}

async function main() {
	var startTime = Date.now();
	processArgs();
	if (mode == "create") {
		createChecksumFile(cwd);
	} else if (mode == "createforeach") {
		createChecksumForEach(cwd);
	} else if (mode == "verify") {
		verifyChecksums(cwd);
	} else if (mode == "verifyall") {
		verifyAllChecksums(cwd);
	}	
	var timeElapsed = Date.now() - startTime;
	cc.log.log("Execution Time: " + cc.stringutil.formatTimeHMSPretty(timeElapsed));
	
	cc.exit(0);
}

main();
