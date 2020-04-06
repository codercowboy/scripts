module.exports = class CCLog {
    constructor() {
        this.debugMode = false;
        this.traceMode = false;
    }

    log(message, object) {
        if (arguments.length > 2) {
            object = [];
            for (var i = 1; i < arguments.length; i++) {
                object.push(arguments[i]);
            }
            console.log(message, object);
        } else if (arguments.length == 2) {
            console.log(message, object);
        }
        console.log(message);
    }
    
    debug(message, object) { if (this.debugMode) { log(message, object); } }
    trace(message, object) { if (this.traceMode) { log(message, object); } }    
    debugobj() {  if (this.debugMode) { this.log("object", arguments); } }
    traceobj() {  if (this.debugMode) { this.log("object", arguments); } }
    
    error(message, object) { 
        log("ERROR: " + message, object);
        if (this.debugMode) { 
            console.trace();
            log("");
        } 
    }
};