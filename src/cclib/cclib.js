const CCLog = require('./cclog.js');

module.exports.log = new CCLog();
module.exports.fileutil = require('./ccfileutil.js');
module.exports.stringutil = require('./ccstringutil.js');
module.exports.collectionutil = require('./cccollectionutil.js');


module.exports.exit = function(exitCode) { process.exit(exitCode); }