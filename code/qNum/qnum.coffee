global.qNum = class qNumPool
  constructor: ->
    @domain        = []
    @numbers       = []
    @ops           = new qNum.Ops this
    @calculators   = []
    
  introduceExtension: (extension) -> 
    @domain.push extension
    
    number.introduceExtension()     for number     in @numbers
    calculator.introduceExtension() for calculator in @calculators
    
    return true
  
  execute: (scope, chunk=null) ->
    if not chunk?
      chunk = scope
      scope = {}
    
    calculator = new qNum.Calculator this, scope
    @calculators.push calculator
    
    calculator.execute chunk
    
    @destroyCalculator calculator
    return calculator.returnScope()
    
  executeRPN: (scope, chunk) ->
    if not chunk?
      chunk = scope
      scope = {}
    
    calculator = new qNum.Calculator this, scope
    @calculators.push calculator
    
    calculator.executeRPN chunk
    
    @destroyCalculator calculator
    return calculator.returnScope()
  
  newCalculator: ->
    calculator = new qNumCalculator this
  
  destroyCalculator: (calculator) ->
    index = @calculators.indexOf calculator
    if index == -1
      throw new Error "Tried to destroy an calculator that has allready been destroyed!"
    @calculators.splice index, 1

global.qNumError = class qNumError extends Error
  constructor: (@message) ->
    @name = "qNumError"

qNum.debug = (lvl) -> (fn) -> if lvl <= qNum.debug.threshold then fn()
qNum.debug.basic = qNum.debug(1)
qNum.debug.extended = qNum.debug(2)
qNum.debug.log = qNum.debug(3)
qNum.debug.threshold = 3

qNum.zero = (n) -> switch
  when n == 0 then new Q 0, 1
  when n >  0 then new X (z = qNum.zero (n-1)), z.copy()
  else throw new qNumError "todo"
  
qNum.one = (domain) ->
  one = new Q 1, 1
  
  for n in [0...domain]
    one = new X one, qNum.zero(n)
    
  return one
    
qNum.extend = (value, domain) ->
  if typeof value == 'number'
    value = new Q value, 1

  for n in [(value.depth)...domain]
    value = new X value, qNum.zero(n)
    
  return value

qNum.deconstruct = (number) -> switch number.type
  when X
    return false unless number.b == qNum.zero(number.b.depth)
    return qNum.deconstruct number.a
  when Q
    return false unless number.d == 1
    return number.n

qNum.Number = class qNumNumber
  id_pool = 0
  
  constructor: (@pool, @value) ->
    @id = id_pool++
      
  copy: -> new Number @pool, @value.copy()
  
  introduceExtension: -> @value = qNum.extend @value, @pool.domain.length
      
  toString: -> "#{@value}:[#{@pool.domain.join(', ')}]"

qNum.X = class X
  @::__defineGetter__ "depth", ->
    return @_depth if @_depth?
    
    qNum.debug.extended =>
      unless @a.depth == @b.depth
        throw new qNumError "Depth inconsistancy when determining depth"
      
    return (@_depth = 1 + @a.depth)
  
  type: X
  toString: -> "(#{@a}, #{@b})"
  
  constructor: (@a, @b) ->
  copy: -> new X @a.copy(), @b.copy()
    
  
qNum.Q = class Q
  type: Q
  depth: 0
  
  toString: -> 
    if @d == 1 then "#{@n}"
    else "#{@n}/#{@d}"
  
  gcd = (a, b) ->
    a = Math.abs a
    b = Math.abs b
    while b != 0 then [a, b] = [b, a % b]
    return a
  
  constructor: (@n, @d) ->
    qNum.debug.basic =>
      unless @n % 1 == 0 and @d % 1 == 0
        throw new qNumError "Horrible! Somehow qNum has introduced a floating number. We might as well quit now. Number = #{@n}/#{@d}"
    
    f = gcd(@n, @d)
    
    if @d < 0
      f *= -1
    
    @n /= f
    @d /= f
    
    qNum.debug.extended =>
      unless @n % 1 == 0 and @d % 1 == 0
        throw new qNumError "Horrible! Somehow qNum has introduced a floating number. We might as well quit now. Number = #{@n}/#{@d}"
    
  copy: -> new Q @n, @d
