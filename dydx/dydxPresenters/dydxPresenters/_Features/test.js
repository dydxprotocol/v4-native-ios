global.calculateWithCb = function(temp,cb){
    cb(5 * temp)
}

global.calculate = function(temp) {
    return 5 * temp
}

function dummyFunction() {
    return 'function';
}
