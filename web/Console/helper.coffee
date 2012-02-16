
window.Console = {}

#  coffee: (line) ->
#    try 
#      snipet = CoffeeScript.compile line, bare: on
#      ret = eval(snipet);
#      if ret? then ret.toString() else 'undefined'
#    catch e
#      e.toString()    

console_index = 0
helper = (object, title, fn) ->
  object.addClass "console"
  object.attr "id", "console-#{console_index}"
  console_index++
  object.console
    promptLabel:      "#{title}"
    commandValidate:  (line) -> line != ""
    commandHandle:    fn
    autofocus:        true
    animateScroll:    true
    promptHistory:    true

Console.make = (title, fn) ->
   console = $('<div>')
   helper console, title, fn
   console
    
Console.fill = (object, title, fn) -> helper object, title, fn