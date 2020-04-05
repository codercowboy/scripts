const fs = require('fs');
const path = require('path');
const cc = require('../cclib/cclib.js');

const CHECKSUM_FILE_NAME = "checksum.md5";

class MD5Result {
	constructor(fileRelativePath, fullFilePath, checksum, source) {
		this.fileRelativePath = fileRelativePath;
		this.fullFilePath = fullFilePath;
		this.checksum = checksum;
		this.source = source;
		this.status = null;
		this.fileDetails = new Object();
		if (cc.fileutil.isFile(fullFilePath)) {
			var stats = fs.statSync(fullFilePath);
			this.fileDetails.basename = path.basename(fullFilePath);
			this.fileDetails.size = stats.size;
			this.fileDetails.modTimeMs = stats.mtimeMs;
		}
	}
}

class MD5ResultMap {
	constructor(md5ResultsArray) {
		this.md5ResultsArray = md5ResultsArray;
		this.mapByRelativePath = new Map();
		this.mapByChecksum = new Map();
		for (var result of md5ResultsArray) {
			if (result.fileRelativePath != null) {
				this.mapByRelativePath.set(result.fileRelativePath, result);
			}
			if (result.checksum != null) {
				var list = this.mapByChecksum.get(result.checksum);
				if (list == null) {
					list = [];
					this.mapByChecksum.set(result.checksum, list);
				}
				list.push(result);
			}
		}
	}

	// returns a list of all of the files
	listFiles() {
		return this.md5ResultsArray;
	}

	// returns a list of files with this checksum
	getFilesWithChecksum(checksum) {
		return this.mapByChecksum.get(checksum);
	}

	// returns the file with this relativePath
	getFileWithRelativePath(relativePath) {
		return this.mapByRelativePath.get(relativePath);
	}
}

class MD5ResultDiff {
	constructor(oldFiles, newFiles) {
		this.oldFilesMap = new MD5ResultMap(oldFiles);
		this.newFilesMap = new MD5ResultMap(newFiles);	

		this.checkedFiles = [];

		this.performDiff();		
	}

	performDiff() {

		/* 
		 * Possible verification statuses for a given file:
		 * 1) file is the same (verified)
		 * 2) file has changed (md5 checksum / size differs)
		 * 3) file is missing 
		 * 4) file is new
		 * 5) file is moved
		 * 6) file is duplicated
		 *
		 * old files: check if they are verified, changed, missing, moved
		 * new files: check if they are new, duplicate of something old, moved old
		 */

		 this.checkedFiles = [];
		 var movedFiles = [];

		 for (let oldFile of this.oldFilesMap.listFiles().values()) {
		 	if (!this.isNewFileExists(oldFile)) {
		 		// old file doesn't exist now, was it moved?
		 		if (this.isOldFileMoved(oldFile)) {
		 			var movedFileRelativePath = this.getFirstDuplicate(oldFile).fileRelativePath;
		 			movedFiles.push(movedFileRelativePath);
		 			oldFile.status = "Moved to " + movedFileRelativePath;
		 		} else {
		 			// old file doesn't exist and it wasn't moved - it's removed
		 			oldFile.status = "Removed";
		 		}
		 	} else {
		 		// old file exists, has it changed?
		 		if (this.isOldFileChanged(oldFile)) {
					oldFile.status = "Changed";
		 		} else {
		 			oldFile.status = "Verified";
		 		}
		 	}
		 	this.checkedFiles.push(oldFile);
		 }

		 for (let newFile of this.newFilesMap.listFiles().values()) {
		 	if (!this.isFileNew(newFile)) {
				//skip files that have already been processed in our 'oldfiles' list
				continue;
			} else if (movedFiles.includes(newFile.fileRelativePath)) {
				//skip files that have already been processed as 'moved' in our oldfiles list
				continue;
			} else if (this.isNewFileADuplicate(newFile)) {
				newFile.status = "Added (Duplicate)";
				this.checkedFiles.push(newFile);
			} else {
				//file is new
				newFile.status = "Added";
		 		this.checkedFiles.push(newFile);
			}
		 }

		 this.checkedFiles = new MD5Lib().sortByRelativePath(this.checkedFiles);
	}

	isOldFileChanged(oldFile) {
		var newFile = this.newFilesMap.getFileWithRelativePath(oldFile.fileRelativePath);
		return (newFile != null && newFile.checksum != oldFile.checksum);
	}

	isNewFileExists(oldFile) {
		return this.newFilesMap.getFileWithRelativePath(oldFile.fileRelativePath) != null;
	}

	isFileNew(newFile) {
		return this.oldFilesMap.getFileWithRelativePath(newFile.fileRelativePath) == null;	
	}

	isNewFileADuplicate(newFile) {
		var oldFiles = this.oldFilesMap.getFilesWithChecksum(newFile.checksum);
		return oldFiles != null && oldFiles.length > 0;
	}

	getNewDuplicatesList(oldFile) {
		var newFiles = this.newFilesMap.getFilesWithChecksum(oldFile.checksum);
		var list = [];
		if (newFiles != null && newFiles.length > 0) {
			for (let newFile of newFiles.values()) {
				if (newFile.fileRelativePath != oldFile.fileRelativePath) {
					list.push(newFile);
				}
			}
		}
		return list; 
	}

	getFirstDuplicate(oldFile) {
		var list = this.getNewDuplicatesList(oldFile);
		return list == null || list.length == 0 ? null : list[0];
	}

	isOldFileMoved(oldFile) {
		return this.getFirstDuplicate(oldFile) != null;
	}

	getCheckedFiles() {
		return this.checkedFiles;
	}
}

class MD5Lib {
	getChecksums(directory) {
		var result = [];
		for (var fileRelativePath of cc.fileutil.listFiles(directory).values()) {
			var fullFilePath = directory + path.sep + fileRelativePath;
			if (cc.fileutil.isDir(fullFilePath)) {
				cc.log.debug("+++ Skipping directory: " + fileRelativePath);
				continue;
			} else if (fullFilePath.indexOf(CHECKSUM_FILE_NAME) != -1) {
				cc.log.debug("+++ Skipping checksum file: " + fileRelativePath);
				continue;
			}
			cc.log.debug("+++ Processing File: " + fileRelativePath);
			var checksum = cc.fileutil.md5(fullFilePath);

			var md5Result = new MD5Result(fileRelativePath, fullFilePath, checksum, "file system");
			result.push(md5Result);
			cc.log.debug("Created MD5Result.", md5Result);
			cc.log.debug("+++ Finished processing file: " + fileRelativePath);
			cc.log.debug("");
		}
		return result;
	}

	readChecksumsFromFile(directory) {
		var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
		cc.log.debug("+++ Reading checksum file: " + checksumFile);
		var fileContents = "" + fs.readFileSync(checksumFile);
		var result = [];
		var lastStatusLine = null;
		var currentResult = new MD5Result(null, null, null);
		var lineNumber = 0;
		for (var line of fileContents.split("\n").values()) {
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

	createChecksumFile(directory) {
		var startTime = Date.now()
		var checksumFile = directory + path.sep + CHECKSUM_FILE_NAME;
		process.stdout.write("Creating: " + checksumFile + " ");
		var md5Results = getChecksums(directory);
		var addTime = new Date().toDateString();
		var totalSize = 0;
		var fileContents = "";
		for (var result of md5Results.values()) {
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

	verifyChecksums(directory) {
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

	sortByRelativePath(md5ResultsArray) {
		if (md5ResultsArray == null || md5ResultsArray.length == 0) {
			return [];
		}
		var map = new Map();
		for (let result of md5ResultsArray.values()) {
			map.set(result.fileRelativePath, result);
		}
		var keys = Array.from(map.keys()).sort();
		var result = [];
		for (let key of keys.values()) {
			result.push(map.get(key));
		}

		return result;
	}
}

module.exports = { MD5Result, MD5ResultMap, MD5ResultDiff, MD5Lib };