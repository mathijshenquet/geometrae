class SelectionAction
    constructor: (@space, e, @mouse) ->
        @selectionLine = [@mouse]
        @selectSegment = new Line (new FreePoint @mouse.x, @mouse.y), (new FreePoint @mouse.x, @mouse.y)
        @space.clearSelection() if not e.ctrlKey
        
    move: (e) ->
        @mouse = {x: e.x, y: e.y}
        
        @selectSegment.p2.x = @mouse.x
        @selectSegment.p2.y = @mouse.y
        @selectSegment.forceCalculate()
        
        return true if @selectSegment.length < (Settings.select.segment_length/@space.box.scale)
        
        @space.shapes.filter((object) -> object.visible).forEach (object) =>
            if not object.selected and Intersection.any(object, @selectSegment)
                object.selected = true
                @space.selection.push(object)
        
        if @selectSegment.length > (Settings.select.segment_jmp/@space.box.scale)
            @selectionLine.push {x: @mouse.x, y: @mouse.y}

            @selectSegment.p1.x = (@selectSegment.p1.x + @selectSegment.p2.x) / 2
            @selectSegment.p1.y = (@selectSegment.p1.y + @selectSegment.p2.y) / 2
            
    end: ->
    
    draw: (ctx) ->
        Draw.selectionLine(ctx, @space, @selectionLine, @mouse)
        
class MakePointAction
    constructor: (@space, e) ->
        @beginPoint = {x: e.x, y: e.y}
    
    move: (e) ->
        if distance(e, @beginPoint) > Settings.point.create_distance
            return false
    
    end: (e) ->
        s = @space.snapGrid(e)
        @space.attach new FreePoint(s.x, s.y)
        
    draw: ->
        
class MovePointAction
    constructor: (@space, e, @point) ->
    
    move: (e) ->
        s = @space.snapGrid(e)
    
        @point.x = s.x
        @point.y = s.y
        
        @point.forceCalculate()
        
    end: ->
    
    draw: ->
        
class MakeObjectAction
    constructor: (@space, e, @beginPoint) ->
        @object = new @ObjectClass @beginPoint, (new FreePoint e.x, e.y)
        
        @object.forceCalculate()
        
    move: (e) ->
        snap = @space.snapPoint(e)

        @object.p2.x = snap.x
        @object.p2.y = snap.y
        
        @object.forceCalculate()
        
    end: (e) ->
        @object.destroy()
        if(nearestPoint = @space.nearestPoint e)
            @object = new @ObjectClass @beginPoint, nearestPoint
            @space.attach @object
        
class MakeLineAction extends MakeObjectAction
    ObjectClass: Line
    draw: (ctx) ->
      Draw.line ctx, @space, @object
    
class MakeCircleAction extends MakeObjectAction
    ObjectClass: Circle
    draw: (ctx) ->
      Draw.circle ctx, @space, @object

class Tool

class DefaultTool extends Tool
    constructor: (@space) ->
        @selectionLine = null
        @action = null

    mousedown: (e) ->
        hit = false

        if (point = @space.nearestPoint(e)) then switch
            when e.ctrlKey && e.button == 0 && point.free
                @action = new MovePointAction(@space, e, point)
        
            when e.button == 2 # right click
                @action = new MakeCircleAction(@space, e, point)
            
            when e.button == 0
                @action = new MakeLineAction(@space, e, point)
        
        else
            @action = new MakePointAction(@space, e)
    
    mousemove: (e) ->
        return null if not @action?
        
        res = @action.move(e)

        if res == false then switch
            when @action instanceof MakePointAction
                @action = new SelectionAction(@space, e, @action.beginPoint)
        
    mouseup: (e) ->
        return null if not @action?

        @action.end(e)
        @action = null
        
    draw: (ctx) ->
        @action.draw(ctx) if @action
        
globalize {DefaultTool}
