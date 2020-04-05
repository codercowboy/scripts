'use strict';

const fs = require('fs');
const exec = require('child_process');
const path = require('path');

const CHECKSUM_FILE_NAME = "checksum.md5";

var debugMode = false;
var testMode = false;

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

function md5(directory, file) {
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
	keys.sort();
	return keys;
}

class MD5Result {
	constructor(fileRelativePath, fullFilePath, checksum, source) {
		this.fileRelativePath = fileRelativePath;
		this.fullFilePath = fullFilePath;
		this.checksum = checksum;
		this.source = source;
		this.fileDetails = new Object();
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
				oldResult.verifyStatus = "VERIFIED";
				this.incrementCount("Verified");
				this.finishedResults.push(oldResult);
				continue;
			} else {
				debugobj(oldResult, newResult);
				oldResult.verifyStatus = "FAILED (" + oldResult.checksum + " -> " + newResult.checksum + ")";
				this.incrementCount("Failed");
				this.incrementCount("Total Errors");
				this.finishedResults.push(oldResult);
				continue;
			}
		}
		var leftoverNewFilesChecksumMap = mapBy(newMap, "checksum");
		for (var oldResult of missingOldResults) {
			var newResult = leftoverNewFilesChecksumMap[oldResult.checksum];
			if (newResult == null) {
				oldResult.verifyStatus = "REMOVED";
				this.incrementCount("Removed");
				this.incrementCount("Total Errors");
				this.finishedResults.push(oldResult);
				continue;
			}
			delete leftoverNewFilesChecksumMap[oldResult.checksum];
			oldResult.verifyStatus = "MOVED -> " + newResult.fileRelativePath;
			this.incrementCount("Moved");
			this.incrementCount("Total Errors");
			finishedResults.push(oldResult);
		}
		for (var newResult of leftoverNewFilesChecksumMap) {
			if (newResult == null) {
				continue;
			}
			newResult.verifyStatus = "ADDED " + addTime;
			this.incrementCount("Added");
			this.incrementCount("Total Errors");
			this.finishedResults.push(newResult);
		}

		for (var key of getSortedKeys(this.finishedResults)) {
			var result = this.finishedResults[key];
			log(result.fileRelativePath + " " + result.verifyStatus);
		}

		log("\nVerification Results");
		for (var countKey of getSortedKeys(this.counts)) {
			log("  " + countKey + ": " + this.counts[countKey]);
		}
		log("\n  Final Status: " + (this.errorsOccurred ? "ERROR" : "SUCCESS"));
	}
	
	incrementCount(countName) {
		if ("Total Errors" == countName) {
			this.errorsOccurred = true;
		}
		if (this.counts[countName] == null) {
			this.counts[countName] = 0;
		}
		this.counts[countName] += 1;
	}
}

function getChecksums(directory) {
	var result = [];
	for (var file of listFiles(directory)) {
		var fullFilePath = directory + path.sep + file;
		if (isDir(fullFilePath)) {
			debug("+++ Skipping directory: " + file);
			continue;
		} else if (isHiddenFile(fullFilePath)) {
			debug("+++ Skipping hidden file: " + file);
			continue;
		} else if (fullFilePath.indexOf(CHECKSUM_FILE_NAME) != -1) {
			debug("+++ Skipping checksum file: " + file);
			continue;
		}
		debug("+++ Processing File: " + file);
		var checksum = md5(directory, file);

		result.push(new MD5Result(file, fullFilePath, checksum, "file system"));
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
			//example line: # File: Eloquent_JavaScript.mobi :: {"basename":"Eloquent_JavaScript.mobi","size":2265889,"modTimeMs":1585984751704.6675}
			debug("Found status line: " + line);
			lastStatusLine = line;
			continue;
		} else if (line.indexOf("#") == 0 || line.trim().length == 0) {
			lastStatusLine = null;
			debug("Skipping line: '" + line + "'");
			continue;
		}
		// example line: 7f2501e1d8c37ad446be0fe0d612d240  blah/Eloquent_JavaScript.mobi # Added Sat Apr 04 2020
		var spaceLocation = line.indexOf(" ");
		var commentLocation = line.indexOf("#");
		if (spaceLocation == -1) {
			error("Cannot parse line #" + lineNumber + ": " + line);
			lastStatusLine = null;
			continue;
		}
		var checksum = line.substr(0, spaceLocation);
		var fileRelativePath = line.substr(spaceLocation + 2);
		if (commentLocation != -1) {
			var length = commentLocation - spaceLocation - 3;
			console.log(length);
			var fileRelativePath = line.substr(spaceLocation + 2, length);
		}		
		var status = commentLocation == -1 ? null : line.substr(commentLocation + 2);

		var md5Result = new MD5Result(fileRelativePath, directory + path.sep + fileRelativePath, checksum, checksumFile);
		md5Result.status = status;
		if (lastStatusLine != null) {
			md5Result.fileDetails = JSON.parse(lastStatusLine.substr(lastStatusLine.indexOf("::") + 3));
		}
		lastStatusLine = null;
		debug("Parsed md5 result.", md5Result);
		result.push(md5Result);
	 }
	 debug("+++ Finished reading checksum file: " + checksumFile);
	 return result;
}

function createChecksumFile(directory) {
	var fileContents = "";
	var md5Results = getChecksums(directory);
	var addTime = new Date().toDateString();
	for (var result of md5Results) {
		var status = "";
		if (result.fileDetails != null) {
			status += "# File: " + result.fileDetails.basename + " :: " + JSON.stringify(result.fileDetails) + "\n";
		}
		status += result.checksum + "  " + result.fileRelativePath;
		if (result.status == null) {
			result.status = "Added " + addTime;
		}
		status += " # " + result.status;
		fileContents += status + "\n";
	}
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	log("Creating: " + checksumFile);
	if (debugMode) {
		debug("Checksum File Contents: \n" + fileContents + "\n\n");
	}
	fs.writeFileSync(checksumFile, fileContents);	
}

function createChecksumForEach(directory) {
	for (var file of fs.readdirSync(directory)) {
		var filePath = directory + path.sep + file;
		if (isDir(file)) {
			createChecksumFile(filePath);
		}
	}
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

async function main() {
	processArgs();
	if (mode == "create") {
		createChecksumFile(cwd);
	} else if (mode == "createforeach") {
		createChecksumForEach(cwd);
	} else if (mode == "verify") {
		verifyChecksums(cwd);
	}	
	
	exit(0);
}

main();
