exports.makeGDLConsole = (app) ->
    interpreter = new GDLInterpreter(app)
    
    $button = $("#gdl_console_button")
    $console = $("#gdl_console")
    
    $button.toggle ->
        $console.slideDown  400, "easeOutQuint"
        $button.addClass "focused"
        $("textarea", $console).focus()
    , ->
        $console.slideUp    400, "easeOutQuint"
        $button.removeClass "focused"
        $("textarea", $console).blur()
        
    if CodeMirror?
        myCodeMirror = CodeMirror($console[0])
        
    if Console?
        input = $("<div>")
        $console.append input
        buffer = ""
        multiline = false
        Console.fill input, "| ", (line) ->
            try
                result = ""
                if not multiline
                    if line == "{"
                        multiline = true
                        result = "begin multiline"
                    else
                        result = interpreter.run line
                else
                    if line == "}"
                        console.log buffer
                        result = interpreter.run buffer
                        buffer = ""
                        multiline = false
                    else
                        buffer += "\n"
                        buffer += line
                        
                return result
            catch e
                return e.message