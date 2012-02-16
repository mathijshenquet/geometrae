isNum = (thing) -> thing.type == qNum.X or thing.type == qNum.Q

qNum.Calculator = class qNumCalculator
  constructor: (@pool, initial) ->
    @stack = []
    @cardinality = 0
    @scope = {}
    
    console.log initial
    
    for name of initial
      item = initial[name]
      
      @addVariable name
      @loadNative item
      @assign()
  
  introduceExtension: ->
    qNum.debug.log =>
      console.log "Adding extension to stack!"
      
    @stack = for thing in @stack
      if isNum thing
        new qNum.X(thing, qNum.zero @pool.domain.length-1)
      else
        thing
  
  # variable mechanism
  
  assign: ->
    qNum.debug.basic => ensureLength.call this, 2
    
    value = prepare.call this, @stack.pop()
    _var = @stack.pop()
    
    qNum.debug.log =>
      console.log "Operation assign:"
      console.log show value
      console.log _var.content
    
    throw new qNumError "Can only assign something to a variable, #{_var} isnt a variable" unless _var.type == 'var'
    
    id = _var.content
    
    if @scope[id]?
      throw new qNumError "#{id} has allready been defined!"
    
    @scope[id] = value
    return this
  
  prepare = (thing) -> tryDeref.call this, thing
  
  prepareNumber = (thing) ->
    thing = tryDeref.call this, thing
    if isNum thing
      thing
    else
      false
      
  prepareBool = (thing) -> 
    thing = tryDeref.call this, thing
    if thing.type == 'bool'
      thing
    else
      false
  
  tryDeref = (thing) -> switch thing.type
    when 'var'
      @deref thing
    else
      thing
      
  deref: (_var) ->
    id = _var.content
    throw new qNumError "Undefined variable #{id}" unless @scope[id]?
    result = @scope[id]
    if result.type == 'var'
      throw new qNumError "Derefed variable is a variable itself, this should not be able to happen!"
    return result
  
  # code for accepting a list of opperations. Like ['1', '2', '+']
  
  executeRawExpression = (expression) ->
    qNum.debug.log => console.log "Execute expression: " + (o.content for o in expression.queue).join ' '
    
    if @cardinality + expression.cardinality_low < 0 # make sure we have enough stuff on the stack to execute the expression
      throw new qNumError "Not enough items on the stack to execute expression!"
      
    last = executeRaw.call this, token for token in expression.queue
    
    @cardinality += expression.cardinality
    unless @cardinality == @stack.length
      throw new qNumError "Cardinality of stack `#{@stack.length}' doesn't match expected cardinality `#{@cardinality}'. Panic!"
      
    return if last == this then @stack[@stack.length-1] else @deref last
    
  executeRaw = (item) ->
    switch item.type
      when 'OPERATOR' then switch item.content
        when '+'  then @add()
        when '-'  then @subtract()
        when '*'  then @multiply()
        when '/'  then @divide()
        when '\\' then @sqrt()
        when '^'
          rawPower = @stack.pop()
          unless (power = qNum.deconstruct rawPower)
            throw new Error "Can't raise to that power! power was: `#{rawPower}'"
          
          fn = (power) ->
            if power < 0
              @reciprocal()
              fn -power
            else if power == 0
              @stack.pop()
              @introduce 1
            else if power == 1
              null
            else if power == 2
              @square()
            else if power % 2
              fn power/2
              @square()
            else
              num = @stack.pop()
              @stack.push num
              fn power-1
              @stack.push num
              @multiply
    
          fn.call this, power
        when '='  then @assign()
        when '==' then @equals()
        when '!=' then @notEquals()
        when '!'  then @_not()
      when 'NUMBER'
        @introduce item.content
      when 'VARIABLE'
        @addVariable item.content
  
  execute:    (chunck) -> 
    executeRawExpression.call this, qNum.Lang.parse    chunck
    return this
    
  executeRPN: (chunck) ->
    executeRawExpression.call this, qNum.Lang.parseRPN chunck
    return this
  
  # helper functions
  
  ensureLength = (n) ->
    unless @stack.length >= n
      throw new qNumError "Stack is of insufficent length to carry out operation (stack.length = #{@stack.length}, should be #{n})"
  
  # expanding the stack (with numbers)

  loadNative: (item) ->
    switch typeof item
      when 'number'
        @introduce item
      when 'object'
        unless item instanceof qNum.Number
          throw new qNumError "Can't add native object to stack of that nature #{item}"
        
        @load item
      when 'string'
        @addVariable item
      else
        throw new qNumError "Can't add native object to stack of that nature #{item}"
  
  addVariable: (value) -> 
    qNum.debug.log => console.log "Adding variable #{value}"
    @stack.push {type: 'var', content: value}
  
  introduce: (n) ->
    qNum.debug.log => console.log "Introducing #{n}"
    
    @stack.push qNum.extend new qNum.Q(n, 1), @pool.domain.length
    
    return this
  
  load: (number) ->
    unless number instanceof Number
      throw new qNumError "Don't try to load things that aint numbers (the qNum kind)"
      
    unless @pool == number.pool
      throw new qNumError "Can't add this number. This number does not belong to this pool."
    
    @stack.push number.value
    
    return this
  
  # numeric operations on the stack
  
  addBinaryOp = (name) =>
    @::[name] = ->
      qNum.debug.basic => ensureLength.call this, 2
      
      unless (a = prepareNumber.call this, @stack.pop()) and 
             (b = prepareNumber.call this, @stack.pop())
        throw new qNumError "Operation `#{name}' invalid on current stack items"
      
      qNum.debug.log =>
        console.log "Operation #{name}:"
        console.log show a
        console.log show b
      
      @stack.push @pool.ops[name] b, a
      return this
  
  addBinaryOp(name) for name in ['add', 'subtract', 'multiply', 'divide']
  
  addUnaryOp = (name) =>
    @::[name] = ->
      qNum.debug.basic => ensureLength.call this, 1
      unless (a = prepareNumber.call this, @stack.pop())
        throw new qNumError "Operation `#{name}' invalid on current stack items"
      
      qNum.debug.log =>
        console.log "Operation #{name}:"
        console.log show a
      
      result = @pool.ops[name] a
      @stack.push result
      return this
  
  addUnaryOp(name) for name in ['square', 'sqrt', 'neg', 'reciprocal']
  
  # boolean operations on the stack
  equals: ->
    qNum.debug.basic => ensureLength.call this, 2

    unless (a = prepareNumber.call this, @stack.pop()) and 
           (b = prepareNumber.call this, @stack.pop())
      throw new qNumError "Operation `#{name}' invalid on current stack items"
    
    result = @pool.ops.equals a, b

    @stack.push {type: 'bool', content: result}
  
  notEquals: ->
    equals = @equals()
    return {type: 'bool', content: not equals.content}
  
  _not: -> 
    qNum.debug.basic => ensureLength.call this, 1

    unless (a = prepareBool.call this, @stack.pop()) 
      throw new qNumError "Operation `#{name}' invalid on current stack items"
    
    @stack.push {type: 'bool', content: not a}
  
  # polling the stack
  
  returnScope: (vars=false) ->
    output = {}
    for _var of @scope
      if not vars or vars.indexOf _var isnt -1
        if isNum @scope[_var]
          value = new qNum.Number @pool, @scope[_var]
          @pool.numbers.push value
        else
          value = @scope[_var].content
          
        output[_var] = value
    
    if @stack.length != 0
      value = new qNum.Number @pool, tryDeref.call this, @stack.pop()
      @pool.numbers.push value
      output['_'] = value
    
    return output
