!function(e){var t={};function i(s){if(t[s])return t[s].exports;var r=t[s]={i:s,l:!1,exports:{}};return e[s].call(r.exports,r,r.exports,i),r.l=!0,r.exports}i.m=e,i.c=t,i.d=function(e,t,s){i.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:s})},i.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},i.t=function(e,t){if(1&t&&(e=i(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var s=Object.create(null);if(i.r(s),Object.defineProperty(s,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)i.d(s,r,function(t){return e[t]}.bind(null,r));return s},i.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return i.d(t,"a",t),t},i.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},i.p="",i(i.s=2)}([function(e,t){e.exports=require("fs")},function(e,t){e.exports=require("path")},function(e,t,i){"use strict";const s=i(0),r=i(1),l=i(3);var o=null,n=null;class u{constructor(e,t,i,o){if(this.fileRelativePath=e,this.fullFilePath=t,this.checksum=i,this.source=o,this.fileDetails=new Object,this.verifyStatus=new Object,l.fileutil.isFile(t)){var n=s.statSync(t);this.fileDetails.basename=r.basename(t),this.fileDetails.size=n.size,this.fileDetails.modTimeMs=n.mtimeMs}}}class a{constructor(e,t){this.errorsOccurred=!1,this.counts=[],this.oldResults=e,this.newResults=t,this.finishedResults=[],this.finishedResultsMap=[];var i=l.collectionutil.mapBy(t,"fileRelativePath"),s=[],r=(new Date).toDateString();for(var o of e){null!=(u=i[o.fileRelativePath])?(delete i[o.fileRelativePath],o.checksum!=u.checksum?(l.log.debugobj(o,u),this.addResult(o,!0,"Failed"," ("+o.checksum+" -> "+u.checksum+")")):this.addResult(o,!1,"Verified",null)):s.push(o)}var n=l.collectionutil.mapBy(i,"checksum");for(var o of s){null!=(u=n[o.checksum])?(delete n[o.checksum],this.addResult(o,!0,"Moved"," -> "+u.fileRelativePath)):this.addResult(o,!0,"Removed",null)}for(var u of n)null!=u&&this.addResult(u,!0,"Added","Added "+r);this.printStatus()}printStatus(){for(var e of l.collectionutil.getSortedKeys(this.finishedResultsMap)){var t=this.finishedResultsMap[e];l.log.log(e+" ("+t.length+" files):");var i=l.collectionutil.mapBy(t,"fileRelativePath");for(var s of l.collectionutil.getSortedKeys(i)){var r=i[s];l.log.log(r.fileRelativePath+" "+r.verifyStatus.description)}l.log.log("")}for(var o of(l.log.log("\nVerification Results"),l.collectionutil.getSortedKeys(this.counts)))l.log.log("  "+o+": "+this.counts[o]);l.log.log("  Final Status: "+(this.errorsOccurred?"ERROR":"SUCCESS")+"\n\n")}addResult(e,t,i,s){s=i.toUpperCase()+(null==s?"":" "+s),e.verifyStatus.description=s,e.verifyStatus.isError=t,e.verifyStatus.status=i.toUpperCase(),this.incrementCount("Total Files"),this.incrementCount(i),t&&(this.incrementCount("Total Errors"),this.errorsOccurred=!0),this.finishedResults.push(e);var r=i.toUpperCase();null==this.finishedResultsMap[r]&&(this.finishedResultsMap[r]=[]),this.finishedResultsMap[r].push(e)}incrementCount(e){null==this.counts[e]&&(this.counts[e]=0),this.counts[e]+=1}getFilesWithStatus(e){var t=[];for(var i of this.finishedResults)-1!=e.verifyStatus.toLowerCase().indexOf(e)&&t.push(i);return t}getVerifiedFiles(){return this.getFilesWithStatus("VERIFIED")}}function c(e){var t=[];for(var i of l.fileutil.listFiles(e)){var s=e+r.sep+i;if(l.fileutil.isDir(s))l.log.debug("+++ Skipping directory: "+i);else if(-1==s.indexOf("checksum.md5")){l.log.debug("+++ Processing File: "+i);var o=l.fileutil.md5(s),n=new u(i,s,o,"file system");t.push(n),l.log.debug("Parsed md5 result.",n),l.log.debug("+++ Finished processing file: "+i),l.log.debug("")}else l.log.debug("+++ Skipping checksum file: "+i)}return t}function f(e){var t=Date.now(),i=e+r.sep+"checksum.md5";process.stdout.write("Creating: "+i+" ");var o=c(e),n=(new Date).toDateString(),u=0,a="";for(var f of o){var d="";null!=f.fileDetails&&(d+="# File: "+f.fileDetails.basename,null==f.status&&(f.status="Added "+n),d+=" :: "+f.status,d+=" # "+JSON.stringify(f.fileDetails)+"\n",u+=f.fileDetails.size),a+=(d+=f.checksum+" *./"+f.fileRelativePath)+"\n"}var g=l.stringutil.formatTimeHMSPretty(Date.now()-t),h="["+o.length+" files, "+l.stringutil.formatFileSizePretty(u)+", "+g+"]";return a+="# Created "+n+" "+h,process.stdout.write(h+"\n"),l.log.debugMode&&l.log.debug("Checksum File Contents: \n"+a+"\n\n"),s.writeFileSync(i,a),{totalSize:u,fileCount:o.length}}function d(e){var t=e+r.sep+"checksum.md5";l.fileutil.isFile(t)||(l.log.error("Checksum file does not exist: "+t),l.exit(1)),log("Verifying: "+t);var i=function(e){var t=e+r.sep+"checksum.md5";l.log.debug("+++ Reading checksum file: "+t);var i=""+s.readFileSync(t),o=[],n=null,a=(new u(null,null,null),0);for(var c of i.split("\n"))if(a+=1,l.log.debug("Processing line #"+a+": "+c),0!=c.indexOf("# File: "))if(0!=c.indexOf("#")&&0!=c.trim().length){var f=c.indexOf(" ");if(-1!=f){var d=c.substr(0,f),g=c.substr(f+4),h=r.dirname(t)+r.sep+g,p=new u(g,h,d,t);if(null!=n){var m=n.indexOf("::"),v=n.substr(2).indexOf("#");p.status=n.substr(m+3,v-m-2);var b=n.substr(v+3);l.log.debugobj(b),p.fileDetails=JSON.parse(b)}n=null,l.log.debug("Parsed md5 result.",p),o.push(p)}else error("Cannot parse line #"+a+": "+c),n=null}else n=null,l.log.debug("Skipping line: '"+c+"'");else l.log.debug("Found status line: "+c),n=c;return l.log.debug("+++ Finished reading checksum file: "+t),o}(e);debug("++ Checksumming files in directory: "+e);var o=c(e);debug("++ Finished checksumming files in directory: "+e);new a(i,o)}!async function(){var e=Date.now();!function(){for(var e of(process.argv.length<3&&(l.log.error("Not enough args."),l.exit(1)),process.argv))"test"==(e=e.toLowerCase())?(l.log.log("Test mode enabled."),testMode=!0,l.log.debugMode=!0):"debug"==e?(l.log.log("Debug mode enabled."),l.log.debugMode=!0):"create"!=e&&"createforeach"!=e&&"verify"!=e&&"verifyall"!=e||(l.log.debug("Mode: "+e),n=e);null==n&&(l.log.error("Execution mode was not specified."),l.exit(1)),o=process.argv[process.argv.length-1],l.fileutil.isDir(o)||(l.log.error("Directory does not exist: "+o),l.exit(1)),o=s.realpathSync(o),l.log.log("Working Directory: "+o)}(),"create"==n?f(o):"createforeach"==n?function(e){var t=0,i=0,o=0;for(var n of s.readdirSync(e)){var u=e+r.sep+n;if(l.fileutil.isDir(u)){var a=f(u);t+=a.totalSize,i+=a.fileCount,o+=1}}l.log.log("Created "+o+" checksum.md5 files. Indexed "+i.toLocaleString()+" files, "+l.stringutil.formatFileSizePretty(t)+".")}(o):"verify"==n?d(o):"verifyall"==n&&function(e){for(var t of l.fileutil.listFiles(e))if(-1!=t.indexOf("checksum.md5")){var i=e+r.sep+t;d(r.dirname(i))}}(o);var t=Date.now()-e;l.log.log("Execution Time: "+l.stringutil.formatTimeHMSPretty(t)),l.exit(0)}()},function(e,t,i){const s=i(4);e.exports.log=new s,e.exports.fileutil=i(5),e.exports.stringutil=i(7),e.exports.collectionutil=i(8),e.exports.exit=function(e){process.exit(e)}},function(e,t){e.exports=class{constructor(){this.debugMode=!1,this.traceMode=!1}log(e,t){if(arguments.length>2){t=[];for(var i=1;i<arguments.length;i++)t.push(arguments[i]);console.log(e,t)}else 2==arguments.length&&console.log(e,t);console.log(e)}debug(e,t){this.debugMode&&this.log(e,t)}trace(e,t){this.traceMode&&this.log(e,t)}debugobj(){this.debugMode&&this.log("object",arguments)}traceobj(){this.debugMode&&this.log("object",arguments)}error(e,t){this.log("ERROR: "+e,t),this.debugMode&&(console.trace(),this.log(""))}}},function(e,t,i){const s=i(0),r=i(1),l=i(6);function o(e){return null!=e&&s.existsSync(e)&&s.statSync(e).isDirectory()}function n(e){return null!=e&&s.existsSync(e)&&s.statSync(e).isFile()}e.exports={isDir:o,isFile:n,isHiddenFile:function(e){return!!n&&"."==r.posix.basename(e).charAt(0)},listFiles:function e(t,i){i=null==i?"":i;var l=s.readdirSync(t),n=[];for(var u of l){var a=t+r.sep+u;if(o(a)){var c=""==i?u:i+r.sep+u;n=n.concat(e(a,c))}else""==i?n.push(u):n.push(i+r.sep+u)}return n.sort(),n},md5:function(e){var t='cd "'+r.dirname(e)+'" && md5sum -b "'+r.basename(e)+'"',i=""+l.execSync(t);return i.substr(0,i.indexOf(" "))}}},function(e,t){e.exports=require("child_process")},function(e,t){e.exports.const={kilobyte:1024,megabyte:1048576,gigabyte:1073741824,terabyte:1099511627776,petabyte:0x4000000000000,millisInSecond:1e3,millisInMinute:6e4,millisInHour:36e5,millisInDay:864e5,millisInWeek:6048e5,millisInYear:31536e6},e.exports.formatFileSizePretty=function(e){var t=null,i=null;if(e>=0x4000000000000)t=0x4000000000000,i="PB";else if(e>=1099511627776)t=1099511627776,i="TB";else if(e>=1073741824)t=1073741824,i="GB";else if(e>=1048576)t=1048576,i="MB";else{if(!(e>=1024))return e.toLocaleString()+" bytes";t=1024,i="KB"}return""+(e=1*e/(1*t)).toFixed(2)+i},e.exports.formatTimeHMSPretty=function(e){var t="",i=0;return e>31536e6&&(e-=31536e6*(i=Math.floor(e/31536e6)),t+=i+"y"),e>6048e5&&(e-=6048e5*(i=Math.floor(e/6048e5)),t+=i+"w"),e>864e5&&(e-=864e5*(i=Math.floor(e/864e5)),t+=i+"d"),e>36e5&&(e-=36e5*(i=Math.floor(e/36e5)),t+=i+"h"),e>6e4&&(e-=6e4*(i=Math.floor(e/6e4)),t+=i+"m"),0==e?t+"0s":t+=(i=(e/1e3).toFixed(3))+"s"}},function(e,t){e.exports={mapBy:function(e,t){var i=[];for(var s of e)null!=s&&(i[s[t]]=s);return i},getSortedKeys:function(e){var t=Object.keys(e);return t.sort((function(e,t){return e.toLowerCase().localeCompare(t.toLowerCase())})),t}}}]);