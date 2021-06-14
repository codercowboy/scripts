const fs = require('fs');
const path = require('path');
const exec = require('child_process');

function isDir(directoryPath) {
    return directoryPath != null && fs.existsSync(directoryPath) && fs.statSync(directoryPath).isDirectory();
};
    
function isFile(filePath) {
    return filePath != null && fs.existsSync(filePath) && fs.statSync(filePath).isFile();
};
    
function isHiddenFile (filePath) {
    if (!isFile) {
        return false;
    }
    var fileBaseName = path.posix.basename(filePath);
    return fileBaseName.charAt(0) == ".";
};

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
};

function md5(filePath) {
	var directory = path.dirname(filePath);
	var file = path.basename(filePath);
	var command = 'cd "' + directory + '" && md5sum -b "' + file + '"';
	var md5ExecOutput = "" + exec.execSync(command);
	return md5ExecOutput.substr(0, md5ExecOutput.indexOf(" "));
}

module.exports = {
    isDir:isDir,
    isFile:isFile,
    isHiddenFile:isHiddenFile,
    listFiles:listFiles,
    md5:md5
};