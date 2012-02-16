if not global? then do ->
    window.global = window
    
if not exports? then do ->
    window.exports = window
    
global.globalize = (obj) ->
    for prop in Object.getOwnPropertyNames(obj)
        global[prop] = obj[prop]
        
    return null

global.show = (thing) -> thing.toString()

private = (name) -> "_#{name}"

global.concat = (arrays...) -> Array.prototype.concat.apply([], arrays)

Function::attr = (name, data) ->
    if not data?
        priv = private(name)
            
        data = {}
        
        data.get     =     -> this[priv]
        data.set     = (v) -> this[priv] = v
    
    data.get ?= ->
    data.set ?= ->
    
    this::__defineSetter__ name, data.set
    this::__defineGetter__ name, data.get
    
`(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame'] 
                                   || window[vendors[x]+'CancelRequestAnimationFrame'];
    }
 
    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); }, 
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };
 
    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());`