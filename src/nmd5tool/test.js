const { MD5Result, MD5ResultMap, MD5ResultDiff, MD5Lib } = require("./md5lib.js");

var oldFiles = [];
oldFiles.push(new MD5Result("verified.txt", "verified.txt", "verified-checksum", "old"));
oldFiles.push(new MD5Result("changed.txt", "changed.txt", "changed-checksum", "old"));
oldFiles.push(new MD5Result("moved.txt", "moved.txt", "moved-checksum", "old"));
oldFiles.push(new MD5Result("removed.txt", "removed.txt", "removed-checksum", "old"));

var newFiles = [];
newFiles.push(new MD5Result("verified.txt", "verified.txt", "verified-checksum", "new"));
newFiles.push(new MD5Result("changed.txt", "changed.txt", "changed-checksum-2", "new"));
newFiles.push(new MD5Result("tmp/moved.txt", "tmp/moved.txt", "moved-checksum", "new"));
newFiles.push(new MD5Result("added.txt", "added.txt", "added-checksum", "new"));
newFiles.push(new MD5Result("added-dupe1.txt", "dupe1.txt", "verified-checksum", "new"));
newFiles.push(new MD5Result("dupes/added-dupe2.txt", "dupe2.txt", "verified-checksum", "new"));

var resultsDiff = new MD5ResultDiff(oldFiles, newFiles);

for (var file of resultsDiff.getCheckedFiles().values()) {
	console.log("File: " + file.fileRelativePath + ", status: " + file.status + ", source: " + file.source);
}