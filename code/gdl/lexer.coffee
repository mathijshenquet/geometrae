# The Lexer Class
# ---------------

# The Lexer class reads a stream of CoffeeScript and divvies it up into tagged
# tokens. Some potential ambiguity in the grammar has been avoided by
# pushing some extra smarts into the Lexer.
global.GDLLexer = class Lexer

  # **tokenize** is the Lexer's main method. Scan by attempting to match tokens
  # one at a time, using a regular expression anchored at the start of the
  # remaining code, or a custom recursive token-matching method
  # (for interpolations). When the next token has been recorded, we move forward
  # within the code past the token, and begin again.
  #
  # Each tokenizing method is responsible for returning the number of characters
  # it has consumed.
  #
  # Before returning the token stream, run it through the [Rewriter](rewriter.html)
  # unless explicitly asked not to.
  tokenize: (code, opts = {}) ->
    code     = "\n#{code}" if WHITESPACE.test code
    code     = code.replace(/\r/g, '').replace TRAILING_SPACES, ''

    @code    = code           # The remainder of the source code.
    @line    = opts.line or 0 # The current line.
    @indent  = 0              # The current indentation level.
    @indebt  = 0              # The over-indentation at the current level.
    @outdebt = 0              # The under-outdentation at the current level.
    @indents = []             # The stack of all current indentation levels.
    @ends    = []             # The stack for pairing up tokens.
    @tokens  = []             # Stream of parsed tokens in the form `['TYPE', value, line]`.

    # At every position, run through this list of attempted matches,
    # short-circuiting if any of them succeed. Their order determines precedence:
    # `@literalToken` is the fallback catch-all.
    i = 0
    while @chunk = code.slice i
      i += @metadataToken()   or
           @commentToken()    or
           @whitespaceToken() or
           @lineToken()       or
           @identifierToken() or
           @symbolToken()     or
           @literalToken()

    @closeIndentation()
    @error "missing #{tag}" if tag = @ends.pop()
    return @tokens if opts.rewrite is off
    (new GDLRewriter).rewrite @tokens

  # Tokenizers
  # ----------
  
  metadataToken: ->
    return 0 unless match = @chunk.match METADATA
    [metadata, label, content] = match
    @token 'METADATA', {label, content}
    @line += 1

    console.log label, content

    metadata.length
    
  identifierToken: ->
    return 0 unless match = @chunk.match IDENTIFIER
    [content] = match
    @token 'IDENTIFIER', content
    content.length
    
  symbolToken: ->
    return 0 unless match = @chunk.match SYMBOL
    [content] = match
    @token 'SYMBOL', content
    content.length
    
  literalToken: ->
    return 0 unless match = @chunk.match /.*/
    [content] = match
    @token 'LITERAL', content
    content.length
  
  # Matches comment
  commentToken: ->
    return 0 unless match = @chunk.match COMMENT
    [comment] = match
    @line += 1
    comment.length

  # Matches newlines, indents, and outdents, and determines which is which.
  # If we can detect that the current line is continued onto the the next line,
  # then the newline is suppressed:
  #
  #     elements
  #       .each( ... )
  #       .map( ... )
  #
  # Keeps track of the level of indentation, because a single outdent token
  # can close multiple indents, so we need to know how far in we happen to be.
  lineToken: ->
    return 0 unless match = MULTI_DENT.exec @chunk
    indent = match[0]
    @line += count indent, '\n'
    @seenFor = no
    prev = last @tokens, 1
    size = indent.length - 1 - indent.lastIndexOf '\n'
    if size - @indebt is @indent
      @newlineToken()
      return indent.length
    if size > @indent
      diff = size - @indent + @outdebt
      @token 'INDENT', diff
      @indents.push diff
      @ends   .push 'OUTDENT'
      @outdebt = @indebt = 0
    else
      @indebt = 0
      @outdentToken @indent - size, false
    @indent = size
    indent.length

  # Record an outdent token or multiple tokens, if we happen to be moving back
  # inwards past several recorded indents.
  outdentToken: (moveOut, noNewlines) ->
    while moveOut > 0
      len = @indents.length - 1
      if @indents[len] is undefined
        moveOut = 0
      else if @indents[len] is @outdebt
        moveOut -= @outdebt
        @outdebt = 0
      else if @indents[len] < @outdebt
        @outdebt -= @indents[len]
        moveOut  -= @indents[len]
      else
        dent = @indents.pop() - @outdebt
        moveOut -= dent
        @outdebt = 0
        
        prev = last @tokens
        prev.newLine = true if prev
        
        @pair 'OUTDENT'
        @token 'OUTDENT', dent
    @outdebt -= moveOut if dent
    @tokens.pop() while @value() is ';'
    @token 'TERMINATOR', '\n' unless @tag() is 'TERMINATOR' or noNewlines
    this

  # Matches and consumes non-meaningful whitespace. Tag the previous token
  # as being "spaced", because there are some cases where it makes a difference.
  whitespaceToken: ->
    return 0 unless (match = WHITESPACE.exec @chunk) or
                    (nline = @chunk.charAt(0) is '\n')
    
    prev = last @tokens
    prev.newLine = true if nline and prev
    
    if match then match[0].length else 0

  # Generate a newline token. Consecutive newlines get merged together.
  newlineToken: ->
    @tokens.pop() while @value() is ';'
    @token 'TERMINATOR', '\n' unless @tag() is 'TERMINATOR'
    this

  # Token Manipulators
  # ------------------
  
  # A source of ambiguity in our grammar used to be parameter lists in function
  # definitions versus argument lists in function calls. Walk backwards, tagging
  # parameters specially in order to make things easier for the parser.
  tagParameters: ->
    return this if @tag() isnt ')'
    stack = []
    {tokens} = this
    i = tokens.length
    tokens[--i].tag = 'PARAM_END'
    while tok = tokens[--i]
      switch tok.tag
        when ')'
          stack.push tok
        when '(', 'CALL_START'
          if stack.length then stack.pop()
          else if tok.tag is '('
            tok.tag = 'PARAM_START'
            return this
          else return this
    this

  # Close up all remaining open blocks at the end of the file.
  closeIndentation: ->
    prev = last @tokens
    prev.newLine = true if prev
    @outdentToken @indent

  # Pairs up a closing token, ensuring that all listed pairs of tokens are
  # correctly balanced throughout the course of the token stream.
  pair: (tag) ->
    unless tag is wanted = last @ends
      @error "unmatched #{tag}" unless 'OUTDENT' is wanted
      # Auto-close INDENT to support syntax like this:
      #
      #     el.click((event) ->
      #       el.hide())
      #
      @indent -= size = last @indents
      @outdentToken size, true
      return @pair tag
    @ends.pop()

  # Helpers
  # -------

  # Add a token to the results, taking note of the line number.
  token: (tag, value) ->
    @tokens.push {tag, value, line: @line}

  # Peek at a tag in the current token stream.
  tag: (index, tag) ->
    (tok = last @tokens, index) and if tag then tok.tag = tag else tok.tag

  # Peek at a value in the current token stream.
  value: (index, val) ->
    (tok = last @tokens, index) and if val then tok.value = val else tok.value

  # Converts newlines for string literals.
  escapeLines: (str, heredoc) ->
    str.replace MULTILINER, if heredoc then '\\n' else ''

  # Constructs a string token by escaping quotes and newlines.
  makeString: (body, quote, heredoc) ->
    return quote + quote unless body
    body = body.replace /\\([\s\S])/g, (match, contents) ->
      if contents in ['\n', quote] then contents else match
    body = body.replace /// #{quote} ///g, '\\$&'
    quote + @escapeLines(body, heredoc) + quote
    
  # Throws a syntax error on the current `@line`.
  error: (message) -> 
    throw SyntaxError "#{message} on line #{ @line + 1}"

# Token matching stuf.
# ---------

COMMENT    = /^(?:---|%|#|\/\/|;).*/

METADATA    = /^#(\w+)(?:[^\S\n]+)?(.*)?/

IDENTIFIER = /// ^
  ( [A-Za-z\x7f-\uffff][$A-Za-z0-9\x7f-\uffff]* )
///

#IDENTIFIER = /[^\s:>?_]+/

SYMBOL = /^[^\sA-Za-z\x7f-\uffff]+/

NUMBER     = ///
  ^ 0x[\da-f]+ |                              # hex
  ^ 0b[01]+ |                              # binary
  ^ \d*\.?\d+ (?:e[+-]?\d+)?  # decimal
///i

WHITESPACE = /^[^\n\S]+/


MULTI_DENT = /^(?:\n[^\n\S]*)+/

# Token cleaning regexes.
MULTILINER      = /\n/g

TRAILING_SPACES = /\s+$/
