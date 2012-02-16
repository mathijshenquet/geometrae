qNum.Lang = {}

qNum.Lang.tokenize = (code) ->
  tokens = []

  match = (regex, fn) -> ->
    unless (match = regex.exec code)
      return false
    
    if (result = fn match)
      tokens.push result

    return match[0].length 
  
  tests = []

  tests.push match /^-?[0-9]+/,   ([number]) -> {type: "NUMBER",      content: +number}
  tests.push match /^[a-zA-Z]+/,  ([id])     -> {type: "VARIABLE",    content: id}
  tests.push match /^[><=!]=/,    ([eq])     -> {type: "OPERATOR",    content: eq,      unary: false}
  tests.push match /^[><]/,       ([eq])     -> {type: "OPERATOR",    content: eq,      unary: false}
  tests.push match /^[\\!]/,      ([unary])  -> {type: "OPERATOR",    content: unary,   unary: true}
  tests.push match /^[+\-*^\/]/,  ([op])     -> {type: "OPERATOR",    content: op,      unary: false}
  tests.push match /^=/,          ([assign]) -> {type: "OPERATOR",    content: assign,  no_return: true}
  tests.push match /^[();\n]/,   ([paren])   -> {type: "PARENTHESIS", content: if paren == '\n' then ';' else paren}
  tests.push match /^\s+/,                   -> false
  
  while code.length != 0
    consumed = false
    for test in tests
      if (consumed = test())
        break
    
    break if not consumed
    code = code.slice consumed

  return tokens

makeAccumulator = ->
  acc = {
    cardinality: 0
    cardinality_low: 0
    queue: []
  }
  
  return {
    push: (token) -> 
      switch token.type
        when 'OPERATOR' 
          acc.cardinality -= if token.unary then 1 else 2
          acc.cardinality_low = acc.cardinality if acc.cardinality < acc.cardinality_low
          acc.cardinality += 1 if not token.no_return
        else acc.cardinality += 1
      acc.queue.push token
    
    result: -> return acc
  }

qNum.Lang.process = (tokens) ->
  accumulator = makeAccumulator()
  accumulator.push token for token in tokens
  return accumulator.result()

LR = 0 #Right to Left assoc
RL = 1 #Left to Right assoc
U  = 2 #Unary

TYPE = 0 # The first field of a token object is the type
CONTENT = 1 # The second field is the content

# The Shunter class recives a list of tokens from the lexer which 
# it reorders using the Shunting yard algorithm by Edsger Dijkstra.
operators =
  '=':  ['=',  -1, RL]
  
  '!':  ['!',  1, U]
  '<':  ['<',  1, RL]
  '>':  ['>',  1, RL]
  '<=': ['<=', 1, RL]
  '>=': ['>=', 1, RL]
  '==': ['==', 1, RL]
  '!=': ['!=', 1, RL]
  
  '+':  ['+',  2, LR]
  '-':  ['-',  2, LR]
  '*':  ['*',  3, LR]
  '/':  ['/',  3, LR]
  '^':  ['^',  4, RL]
  
  '\\': ['\\', 5, U]

prec  = (op) -> operators[op]?[1]
assoc = (op) -> operators[op]?[2]
last = (ar, n=0) -> ar[ar.length-(n+1)]

qNum.Lang.shunt = (tokens) ->
  stack  = []
  accumulator = makeAccumulator()
    
  for token in tokens
    switch token.type
      when 'OPERATOR'
        op = token.content
      
        while (prev = last(stack)?.content) and (((assoc(op) == LR or assoc(op) == U) and prec(op) <= prec(prev)) or (assoc(op) == RL and prec(op) <= prec(prev)))
          accumulator.push stack.pop()
          
        stack.push token
      when 'PARENTHESIS' then switch token.content
        when '('
          stack.push token
        when ')'
          while (item = stack.pop()) and item.content != '('
            accumulator.push item
            
          throw new Error("Unbalanced parenthesis!") unless item.content == '('
        when ';'
          while (item = stack.pop()) and item.content != '('
            accumulator.push item
            
          throw new qNumError "Unbalanced parenthesis!" if item == '('
      
        else throw new Error("Invalid token detected, type was `Parenthesis' but content #{token.content}")
        
      when 'NUMBER'
        accumulator.push token
      when 'VARIABLE'
        accumulator.push token
  
  while (item = stack.pop()) and item.content != '('
    accumulator.push item
    
  throw new qNumError "Unbalanced parenthesis!" if item == '('
  
  return accumulator.result()

qNum.Lang.parse = (input) -> qNum.Lang.shunt qNum.Lang.tokenize input

qNum.Lang.parseRPN = (input) -> qNum.Lang.process qNum.Lang.tokenize input