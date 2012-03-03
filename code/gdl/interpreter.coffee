class GDLError extends Error
  name: 'GDLError'
  constructor: (msg) ->
    super("GDLError Fatal: #{msg}")

global.GDLInterpreter = class GDLInterpreter
  constructor: (@app) ->
    @lexer = new GDLLexer
    @parser = new GDLParser
      
  run: (code) ->
    env = new GDLEnv(@app)
    tokens = @lexer.tokenize code
    console.log ("#{t[1]}:#{t[0]}" for t in tokens)
    ast = @parser.parse tokens
    console.log (a for a in ast)
    ins = @construct ast
    result = @evaluate ins, env
    env.resolution = result
    
    console.log env
    
    if env.resolution
      @export(env)
    
    return "#{env.resolution}"
  
  export: (env) ->
    objects = (env.entity[e] for own e of env.entity).filter ((o) -> env.importList.indexOf(o) == -1)
    (env.app.addObject object for object in objects)
  
  evaluate: (instructions, env, opts={}) ->
    opts.reverse = false
    
    if not opts.reverse
      fallback = false
      pointer = 0
    else
      fallback = true
      pointer = instructions.length - 1
        
    resolution = null
    
    while resolution == null
      if not fallback
        console.log instructions[pointer]
        result = instructions[pointer].execute(env)
    
        if result
          pointer += 1
        else
          fallback = true
          pointer -= 1
      else
        console.log instructions[pointer]
        result = instructions[pointer].reverse(env)
          
        if result
          pointer -= 1
        else
          fallback = false
          pointer += 1
                
      resolution = false if pointer == -1
      resolution = true  if pointer == instructions.length
        
    return resolution
            
  construct: (ast) ->
    for i in ast
      switch i.type
        when 'METADATA' then new GDLMetadataExpr    this, i.label,      i.content
        when 'DEFINE'   then new GDLDefineExpr      this, i.id,         i.op,     i.arguments
        when 'INPUT'    then new GDLInputExpr       this, i.id,         i.object
        when 'VALIDATE' then new GDLValidateExpr    this, i.op,     i.arguments
        when 'SWITCH'   then new GDLSwitchExpr      this, (@construct branch for branch in i.branches)

class GDLEnv
  constructor: (@app) ->
    @metadata   = {}
    @entity     = {}
    @resolution = null
    @importList = []
  
  isImported: (object) -> @importList.indexOf(object) != -1
  
  importListAdd: (object) ->
    if @isImported object
      throw new GDLError("Tried to add an object to the importList that is allready on that list")
        
    @importList.push object
    
  importListRemove: (object) ->
    if not @isImported object
      throw new GDLError("Tried to remove an object from the importList that not on that list")
      
    @importList.splice @importList.indexOf(object), 1
  
  setMetadata: (label, content) ->
    @metadata[label] = [] if not @metadata[label]?
    @metadata[label].unshift(content)
      
  unsetMetadata: (label) ->
    if not @metadata[label]? or @metadata[label].length == 0
      throw new GDLError("Runtime error, somehow we tried to remove metadata that has not been created.")
        
    @metadata[label].shift()
      
  getMetadata: (label) ->
    @metadata[label][0]
      
  # entities
      
  mkEntity: (id, value) ->
    if @entity[id]?
      throw new GDLError("Tried to define an entity with the same name. This is an invalid operation: Variables can be defined only once.")
    
    @entity[id] = value

  rmEntity: (id) ->
    @entity[id] = null
  
  getEntity: (id) -> 
    if not @entity[id]?
      throw new GDLError("Tried to retrive a non existent entity.")
          
    @entity[id]

class GDLExpr

class GDLMetadataExpr extends GDLExpr
  constructor: (@interpreter, @label, @content) ->
  
  execute: (env) ->
    env.setMetadata   @label, @content
    return true
      
  reverse: (env) ->
    env.unsetMetadata @label
    return true
  
class GDLDefineExpr extends GDLExpr
  constructor: (@interpreter, @id, op, @arguments) ->
    throw new GDLError("To much arguments for define expression (#{@arguments})") if @arguments.length != 2
    
    switch op
      when 'lijn'     then @cls = Line
      when 'cirkel'   then @cls = Circle
      when 'punt'     then @cls = Point
      when '_'        then @op  = 'deconstruct'
      
    @op = 'create' if @cls?
  
  execute: (env) ->
    console.log @op
    
    obj = switch @op
      when 'create'
        a = env.getEntity @arguments[0]
        b = env.getEntity @arguments[1]
        
        new @cls(a, b)
      when 'deconstruct'
        target = env.getEntity @arguments[0]
        field = @arguments[1]
        target[field]
    
    console.log "something"
    console.log obj
    
    env.mkEntity @id, obj
    return true
      
  reverse: (env) -> 
    env.rmEntity @id
    return true
        
class GDLInputExpr extends GDLExpr
  constructor: (@interpreter, @id, @object) ->
    @i = null
      
  defineNext: (env) ->
    while true
      if @i == @collection.length
        return false # we failed to define the next one
        
      object = @collection[@i]
      @i++
      
      if env.isImported object
        continue # skip this object, we allready have that one imported

      env.mkEntity @id, object
      env.importListAdd object
      
      return true # definition sucseeded
      
  execute: (env) ->
    @collection = switch @object
        when 'punt'     then env.app.points
        when 'cirkel'   then env.app.circles
        when 'lijn'     then env.app.lines
    @i = 0
    
    return @defineNext(env)
  
  reverse: (env) ->
    env.importListRemove env.getEntity @id
    env.rmEntity @id
    
    return not @defineNext(env)

class GDLValidateExpr extends GDLExpr
  constructor: (@interpreter) ->
    throw new GDLError "Not implemented jet (validation expressions)"

class GDLSwitchExpr extends GDLExpr
  constructor: (@interpreter, @branches) ->
    @active_branch = null
      
  execute: (env) ->
    if @active_branch?
      throw new GDLError "Runtime error, somehow a switch statement was reexecuted before being reversed."
    
    resolution = false
    
    for branch, index in @branches
      result = @interpreter.evaluate(branch, env)
      if result == true
        resolution = true
        @active_branch = index
        break

    return resolution
      
  reverse: (env) ->
    @interpreter.execute @branches[@active_branch], env, {reverse: true}
    @active_branch = null
