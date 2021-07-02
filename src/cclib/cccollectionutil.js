function mapBy(itemArray, propertyName) {
	// Map reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map
	var map = new Map();
	if (itemArray == null || propertyName == null || itemArray.length == 0) {
		return map;
	}
	for (var item of itemArray.values()) {
		if (item == null || item[propertyName] == null) {
			continue;
		}
		map.set(item[propertyName], item);
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