
exports.GDLParser = class Parser
    parse: (tokens) ->
        tree = []
        @indent = 0
        while tokens.length > 0 then @feed(tokens, tree)
        return tree
        
    feed: (tokens, result) ->
        @indentationCatcher(tokens, result) or
        @metadataStatement(tokens, result)  or 
        @inputStatement(tokens, result)     or
        @probeerStatement(tokens, result)   or
        @defineStatement(tokens, result)    or
        @validateStatement(tokens, result)  or
        @junkStatement(tokens, result)
        
    indentationCatcher: (tokens, result) ->
        if tokens[0][TYPE] == "INDENT"
            @indent++
            tokens.shift()
            return true
        else if tokens[0][TYPE] == "OUTDENT"
            @indent--
            tokens.shift()
            return true
            
        return false
        
    metadataStatement: (tokens, result) ->
        return false if tokens[0][TYPE] != 'METADATA'
        
        token = tokens.shift()
        statement =
            type: "METADATA"
            label: token[CONTENT].label
            content: token[CONTENT].content
        
        result.push statement
        return true
        
    probeerStatement: (tokens, result) ->
        return false unless (
            tokens[0][TYPE] == 'IDENTIFIER' and
            tokens[0][CONTENT] == 'probeer'
            )
        
        tokens.shift()
        
        branches = []
        
        while true
            throw new Error("Malformed probeer statement at line #{tokens[0][LINE]}") if not (
                tokens[0][TYPE] == 'INDENT'
            )
            
            branch = []
            
            currentIndent = @indent
            @indentationCatcher(tokens)
            
            while currentIndent != @indent then @feed(tokens, branch)
            
            branches.push branch
            
            break unless (
                tokens[0][TYPE] == 'IDENTIFIER' and
                tokens[0][CONTENT] == 'anders'
                )

            tokens.shift()
        
        console.log branches
        
        statement =
            type: "SWITCH"
            branches: branches
            
        result.push statement
        return true
        
    inputStatement: (tokens, result) ->
        return false unless (
            tokens[0][TYPE] == 'SYMBOL' and 
            tokens[0][CONTENT] == ">")
            
        throw new Error("Malformed input statement at line #{tokens[0][LINE]}") if not (
            tokens[1][TYPE] == 'IDENTIFIER' and
            tokens[2][TYPE] == 'IDENTIFIER' and
            tokens[2][NEWLINE] == true
            )
        
        tokens.shift()
        object = tokens.shift()[CONTENT]
        id = tokens.shift()[CONTENT]
        statement =
            type: "INPUT"
            id: id
            object: object
        
        result.push statement
        return true
        
    validateStatement: (tokens, result) ->
      return false unless (
        tokens[0][TYPE] == 'SYMBOL' and 
        tokens[0][CONTENT] == "?" and
        tokens[0][NEWLINE] != true)
      
      tokens.shift()
      
      if tokens[1][TYPE] == 'SYMBOL'
        unless tokens[0][NEWLINE] != true and tokens[0][TYPE] == 'IDENTIFIER' and tokens[1][NEWLINE] != true and tokens[2][NEWLINE] == true and tokens[2][TYPE] == 'IDENTIFIER'
          throw new Error("Malformed binary validation statement at line #{tokens[0][LINE]}")
        
        arguments = []
        arguments.push tokens.shift()[CONTENT]
        op = tokens.shift()[CONTENT]
        arguments.push tokens.shift()[CONTENT]
        
        statement =
          type: "VALIDATE"
          op: op
          arguments: arguments
      
      else
        op = tokens.shift()[CONTENT]
        
        arguments = []
        
        while true
          unless tokens[0][TYPE] == 'IDENTIFIER'
            throw new Error("Malformed validation statement at line #{tokens[0][LINE]}")
          eol = tokens[0][NEWLINE] == true
          arguments.push tokens.shift()[CONTENT]
          break if eol
      
        statement =
          type: "VALIDATE"
          op: op
          arguments: arguments
      
      result.push statement
      return true
        
    defineStatement: (tokens, result) ->
      return false if not (
          tokens[0][TYPE]     == 'IDENTIFIER' and 
          
          tokens[1][TYPE]     == 'SYMBOL' and 
          tokens[1][CONTENT]  == ':')
          
      id = tokens.shift()[CONTENT]
      tokens.shift()
      
      if tokens[1][TYPE] == 'SYMBOL'
        unless tokens[0][NEWLINE] != true and tokens[0][TYPE] == 'IDENTIFIER' and tokens[1][NEWLINE] != true and tokens[2][NEWLINE] == true and tokens[2][TYPE] == 'IDENTIFIER'
          throw new Error("Malformed binary definition statement at line #{tokens[0][LINE]}")
        
        arguments = []
        arguments.push tokens.shift()[CONTENT]
        op = tokens.shift()[CONTENT]
        arguments.push tokens.shift()[CONTENT]
        
        statement =
          type: "DEFINE"
          id: id
          op: op
          arguments: arguments
      
      else
        op = tokens.shift()[CONTENT]
        
        arguments = []
        
        while true
          unless tokens[0][TYPE] == 'IDENTIFIER'
            throw new Error("Malformed definition statement at line #{tokens[0][LINE]}")
          eol = tokens[0][NEWLINE] == true
          arguments.push tokens.shift()[CONTENT]
          
          break if eol
      
        statement =
          type: "DEFINE"
          id: id
          op: op
          arguments: arguments

      result.push statement
      return true
                
    junkStatement: ->
        throw new Error("Malformed line at #{tokens[0][LINE]}")
        
TYPE = 0
CONTENT = 1
LINE = 2
NEWLINE = 'newLine'
