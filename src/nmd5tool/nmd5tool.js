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

function debugobj(object) { debug("object", object); }

function error(message, object) { 
	log("ERROR: " + message, object);
	if (debugMode) { 
		console.trace();
		log("");
	} 
}

function isDir(directoryPath) {
	return fs.existsSync(directoryPath) && fs.lstatSync(directoryPath).isDirectory();
}

function isFile(filePath) {
	return fs.existsSync(filePath) && fs.lstatSync(directoryPath).isFile();
}

function isHiddenFile(filePath) {
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
		} else if ("CREATE" == arg || "CREATEFOREACH" == arg
			|| "CHECK" == arg || "CHECKALL" == arg) {
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

class MD5Result {
	constructor(fileRelativePath, fullFilePath, checksum) {
		this.fileRelativePath = fileRelativePath;
		this.fullFilePath = fullFilePath;
		this.checksum = checksum;
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
		}
		debug("+++ Processing File: " + file);
		var checksum = md5(directory, file);

		result.push(new MD5Result(file, fullFilePath, checksum));
		debug("+++ Finished processing file: " + file);
		debug("");
	}
	return result;
}

function createChecksumFile(directory) {
	var fileContents = "";
	var md5Results = processFiles(directory);
	for (var result of md5Results) {
		fileContents += result.checksum + "  " + result.fileRelativePath + "\n";
	}
	var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
	log("Creating: " + checksumFile);
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
	debug("++ Checksumming files in directory: " + directory);
	var md5Results = processFiles(directory);
	debug("++ Finished checksumming files in directory: " + directory);
}

async function main() {
	processArgs();
	if (mode == CREATE) {
		createChecksumFile(cwd);
	} else if (mode == CREATEFOREACH) {
		createChecksumForEach(cwd);
	} else if (mode == CHECK) {
		verifyChecksums(cwd);
	}	
	
	exit(0);
}

main();







  
//   async function asyncCall() {
// 	console.log('calling');
// 	const result = await resolveAfter2Seconds();
// 	console.log(result);
// 	// expected output: 'resolved'
//   }

//   log("slept");
  
//   asyncCall();

