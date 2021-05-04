const kilobyte = 1024;
const megabyte = kilobyte * 1024;
const gigabyte = megabyte * 1024;
const terabyte = gigabyte * 1024;
const petabyte = terabyte * 1024;

const millisInSecond = 1000;
const millisInMinute = 60 * millisInSecond;
const millisInHour = 60 * millisInMinute;
const millisInDay = 24 * millisInHour;
const millisInWeek = 7 * millisInDay;
const millisInYear = 365 * millisInDay;

module.exports.const = {
    kilobyte:kilobyte,
    megabyte:megabyte,
    gigabyte:gigabyte,
    terabyte:terabyte,
    petabyte:petabyte,
    millisInSecond:millisInSecond,
    millisInMinute:millisInMinute,
    millisInHour:millisInHour,
    millisInDay:millisInDay,
    millisInWeek:millisInWeek,
    millisInYear:millisInYear
};

module.exports.formatFileSizePretty = function(byteCount) {
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
};

module.exports.formatTimeHMSPretty = function(milliseconds) {
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
};