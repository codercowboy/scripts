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

module.exports = {
	mapBy:mapBy,
	getSortedKeys:getSortedKeys
}