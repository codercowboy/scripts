const path = require('path');

module.exports = {
	entry: './nmd5tool.js',
	output: {
		filename: 'nmd5tool.js',
		path: path.resolve(__dirname, 'dist'),
	},
	target:'node',
	mode:'production'
};