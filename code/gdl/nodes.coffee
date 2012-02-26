class GDLNamedExpression


class GDLMetadata
  constructor: (@label, @content) ->

class GDLInput
  constructor: (@id, object)

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