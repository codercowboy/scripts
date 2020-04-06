/*
	TODO:

	* Add verbose mode 
	* verifyall should aggregate stats	
	* add tests, need to test all error case paths ie removed, moved, added
	* figure out how to webpack a distributable version
	* add copyright license notice
	* add usage

	Future Features:

	* Add update checksum mode.
	* Add joinall etc from old script
	* Move lib functions to a lib.js
*/

'use strict';

const fs = require('fs');
const exec = require('child_process');
const path = require('path');

const CHECKSUM_FILE_NAME = "checksum.md5";

var debugMode = false;
var testMode = false;

const kilobyte = 1024;
const megabyte = kilobyte * 1024;
const gigabyte = megabyte * 1024;
const terabyte = gigabyte * 1024;
const petabyte = terabyte * 1024;

function getFileSizePretty(byteCount) {
	var divisor = null;
	var label = null;
	if (byteCount >= petabyte) {
		divisor = petabyte;
		label = "PB";
	} else if (byteCount >= terabyte) {
		divisor = terabyte;
		label = "TB";
	} else if (byteCount >= gigabyte) {
		divisor = gigabyte;
		label = "GB";
	} else if (byteCount >= megabyte) {
		divisor = megabyte;
		label = "MB";
	} else if (byteCount >= kilobyte) {
		divisor = kilobyte;
		label = "KB";
	} else {
		return "" + byteCount.toLocaleString() + " bytes";
	}
	byteCount = ((byteCount * 1.0) / (divisor * 1.0));
	return "" + byteCount.toFixed(2) + label;
}

const millisInSecond = 1000;
const millisInMinute = 60 * millisInSecond;
const millisInHour = 60 * millisInMinute;
const millisInDay = 24 * millisInHour;
const millisInWeek = 7 * millisInDay;
const millisInYear = 365 * millisInDay;

function getTimeHMSPretty(milliseconds) {
	var result = "";
	var tmpAmount = 0;
	if (milliseconds > millisInYear) {
		tmpAmount = Math.floor(milliseconds / millisInYear);
		milliseconds -= (tmpAmount * millisInYear);
		result += tmpAmount + "y";
	}
	if (milliseconds > millisInWeek) {
		tmpAmount = Math.floor(milliseconds / millisInWeek);
		milliseconds -= (tmpAmount * millisInWeek);
		result += tmpAmount + "w";
	}
	if (milliseconds > millisInDay) {
		tmpAmount = Math.floor(milliseconds / millisInDay);
		milliseconds -= (tmpAmount * millisInDay);
		result += tmpAmount + "d";
	}
	if (milliseconds > millisInHour) {
		tmpAmount = Math.floor(milliseconds / millisInHour);
		milliseconds -= (tmpAmount * millisInHour);
		result += tmpAmount + "h";
	}
	if (milliseconds > millisInMinute) {
		tmpAmount = Math.floor(milliseconds / millisInMinute);
		milliseconds -= (tmpAmount * millisInMinute);
		result += tmpAmount + "m";
	}
	if (milliseconds == 0) {
		return result + "0s";
	}
	tmpAmount = (milliseconds / millisInSecond).toFixed(3);
	result += tmpAmount + "s";
	return result;
}

function log(message, object) {
	if (object == null) {
		console.log(message);
	} else {
		console.log(message, object);
	}
}
function debug(message, object) { if (debugMode) { log(message, object); } }

function debugobj() { 
	var object = [];
	for (var i = 0; i < arguments.length; i++) {
		object.push(arguments[i]);
	}
	debug("object", arguments.length == 1 ? arguments[0] : object); 
}

function error(message, object) { 
	log("ERROR: " + message, object);
	if (debugMode) { 
		console.trace();
		log("");
	} 
}

function isDir(directoryPath) {
	return directoryPath != null && fs.existsSync(directoryPath) && fs.statSync(directoryPath).isDirectory();
}

function isFile(filePath) {
	return filePath != null && fs.existsSync(filePath) && fs.statSync(filePath).isFile();
}

function isHiddenFile(filePath) {
	if (!isFile) {
		return false;
	}
	var fileBaseName = path.posix.basename(filePath);
	return fileBaseName.charAt(0) == ".";
}

function exit(exitCode) { process.exit(exitCode); }

var cwd = null;
var mode = null;

function processArgs() {
	if (process.argv.length < 3) {
		error("Not enough args.");
		exit(1);
	}

	for (var arg of process.argv) {
		arg = arg.toLowerCase();
		if ("test" == arg) {
			log("Test mode enabled.");
			testMode = true;
			debugMode = true;
		} else if ("debug" == arg) {
			log("Debug mode enabled.");
			debugMode = true;
		} else if ("create" == arg || "createforeach" == arg
			|| "verify" == arg || "verifyall" == arg) {
			debug("Mode: " + arg);
			mode = arg;
		}
	}

	if (mode == null) {
		error("Execution mode was not specified.");
		exit(1);
	}

	cwd = process.argv[process.argv.length - 1];

	if (!isDir(cwd)) {
		error("Directory does not exist: " + cwd);
		exit(1);
	}

	cwd = fs.realpathSync(cwd);
	log("Working Directory: " + cwd);
}

function md5(filePath) {
	var directory = path.dirname(filePath);
	var file = path.basename(filePath);
	var command = 'cd "' + directory + '" && md5sum -b "' + file + '"';
	debug("Executing md5sum command: " + command);
	var md5ExecOutput = "" + exec.execSync(command);
	return md5ExecOutput.substr(0, md5ExecOutput.indexOf(" "));
}

function listFiles(directory, prefixSoFar) {
	prefixSoFar = prefixSoFar == null ? "" : prefixSoFar;
	var files = fs.readdirSync(directory);
	var result = []
	for (var file of files) {
		var fullPath = directory + path.sep + file;
		if (isDir(fullPath)) {
			var prefix = (prefixSoFar == "") ? file : (prefixSoFar + path.sep + file);			
			result = result.concat(listFiles(fullPath, prefix));
		} else {
			if (prefixSoFar == "") {
				result.push(file);
			} else {
				result.push(prefixSoFar + path.sep + file);
			}
		}
	}
	result.sort();
	return result;
}

function mapBy(itemArray, propertyName) {
	var map = [];
	for (var item of itemArray) {
		if (item == null) {
			continue;
		}
		map[item[propertyName]] = item;
	}
	return map;
}

function getSortedKeys(array) {
	var keys = Object.keys(array);
	keys.sort(function (a, b) {
		return a.toLowerCase().localeCompare(b.toLowerCase());
	});
	return keys;
}

class MD5Result {
	constructor(fileRelativePath, fullFilePath, checksum, source) {
		this.fileRelativePath = fileRelativePath;
		this.fullFilePath = fullFilePath;
		this.checksum = checksum;
		this.source = source;
		this.fileDetails = new Object();
		this.verifyStatus = new Object();
		if (isFile(fullFilePath)) {
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
		
		var newMap = mapBy(newResults, "fileRelativePath");
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
				debugobj(oldResult, newResult);
				this.addResult(oldResult, true, "Failed", " (" + oldResult.checksum + " -> " + newResult.checksum + ")");
				continue;
			}
		}
		var leftoverNewFilesChecksumMap = mapBy(newMap, "checksum");
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
		for (var key of getSortedKeys(this.finishedResultsMap)) {
			var results = this.finishedResultsMap[key]; 
			log(key + " (" + results.length + " files):");
			var resultsMap = mapBy(results, "fileRelativePath");
			for (var resultKey of getSortedKeys(resultsMap)) {
				var result = resultsMap[resultKey];
				log(result.fileRelativePath + " " + result.verifyStatus.description);
			}	
			log("");		
		}

		log("\nVerification Results");
		for (var countKey of getSortedKeys(this.counts)) {
			log("  " + countKey + ": " + this.counts[countKey]);
		}
		log("  Final Status: " + (this.errorsOccurred ? "ERROR" : "SUCCESS") + "\n\n");
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
	for (var file of listFiles(directory)) {
		var fullFilePath = directory + path.sep + file;
		if (isDir(fullFilePath)) {
			debug("+++ Skipping directory: " + file);
			continue;
		} else if (fullFilePath.indexOf(CHECKSUM_FILE_NAME) != -1) {
			debug("+++ Skipping checksum file: " + file);
			continue;
		}
		debug("+++ Processing File: " + file);
		var checksum = md5(fullFilePath);

		var md5Result = new MD5Result(file, fullFilePath, checksum, "file system");
		result.push(md5Result);
		debug("Parsed md5 result.", md5Result);
		debug("+++ Finished processing file: " + file);
		debug("");
	}
	return result;
}

function readChecksumsFromFile(directory) {
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	debug("+++ Reading checksum file: " + checksumFile);
	var fileContents = "" + fs.readFileSync(checksumFile);
	var result = [];
	var lastStatusLine = null;
	var currentResult = new MD5Result(null, null, null);
	var lineNumber = 0;
	for (var line of fileContents.split("\n")) {
		lineNumber += 1;
		debug("Processing line #" + lineNumber + ": " + line);
		if (line.indexOf("# File: ") == 0) {
			//example line: # File: file.mobi :: Added Sat Apr 04 2020 # {"basename":"file.mobi","size":2265889,"modTimeMs":1585984751704}
			debug("Found status line: " + line);
			lastStatusLine = line;
			continue;
		} else if (line.indexOf("#") == 0 || line.trim().length == 0) {
			lastStatusLine = null;
			debug("Skipping line: '" + line + "'");
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
			debugobj(json);
			md5Result.fileDetails = JSON.parse(json);
		}
		lastStatusLine = null;
		debug("Parsed md5 result.", md5Result);
		result.push(md5Result);
	 }
	 debug("+++ Finished reading checksum file: " + checksumFile);
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
	var timeElapsed = getTimeHMSPretty(Date.now() - startTime);
	var message = "[" + md5Results.length + " files, " + getFileSizePretty(totalSize) + ", " + timeElapsed + "]";
	fileContents += "# Created " + addTime + " " + message;
	process.stdout.write(message + "\n");
	if (debugMode) {
		debug("Checksum File Contents: \n" + fileContents + "\n\n");
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
		if (isDir(filePath)) {
			var result = createChecksumFile(filePath);
			totalSize += result.totalSize;
			fileCount += result.fileCount;
			checksumFileCount += 1;
		}
	}
	console.log("Created " + checksumFileCount + " " + CHECKSUM_FILE_NAME + " files. Indexed " 
		+ fileCount.toLocaleString() + " files, " + getFileSizePretty(totalSize) + ".");
}

function verifyChecksums(directory) {
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	if (!isFile) {
		error("Checksum file does not exist: " + checksumFile);
		exit(1);
	}
	log("Verifying: " + checksumFile);
	var oldResults = readChecksumsFromFile(directory);
	debug("++ Checksumming files in directory: " + directory);
	var currentResults = getChecksums(directory);
	debug("++ Finished checksumming files in directory: " + directory);
	var diff = new MD5ResultDiff(oldResults, currentResults);
}

function verifyAllChecksums(directory) {
	for (var file of listFiles(directory)) {
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
	log("Execution Time: " + getTimeHMSPretty(timeElapsed));
	
	exit(0);
}

main();
