class SelectionAction
    constructor: (@space, e, opts={}) ->
        opts.keep ?= false

        @selectionLine = [{x: e.x, y: e.y}]
        @selectSegment = new Line (new FreePoint e.x, e.y), (new FreePoint e.x, e.y)
        @space.clearSelection() if not opts.keep
        
    update: (e) ->
        @mouse = {x: e.x, y: e.y}
        
        @selectSegment.p2.x = @mouse.x
        @selectSegment.p2.y = @mouse.y
        @selectSegment.forceCalculate()
        
        return true if @selectSegment.length < (Settings.select.segment_length/@space.box.scale)
        
        @space.shapes.filter((object) -> object.visible and not object.selected).forEach (object) =>
            if Intersection.has(object, @selectSegment)
                @space.selectionAdd(object)
        
        if @selectSegment.length > (Settings.select.segment_jmp/@space.box.scale)
            @selectionLine.push {x: @mouse.x, y: @mouse.y}

            @selectSegment.p1.x = (@selectSegment.p1.x + @selectSegment.p2.x) / 2
            @selectSegment.p1.y = (@selectSegment.p1.y + @selectSegment.p2.y) / 2
            
    end: ->
    
    draw: (ctx) ->
        Draw.selectionLine(ctx, @space, @selectionLine, @mouse)

class TranslateAction
    constructor: (@space, @origin) ->
        @begin_center_x = @space.box.center_x
        @begin_center_y = @space.box.center_y

    update: (e) ->
        @space.box.center_x = @begin_center_x + (e.realX - @origin.realX)
        @space.box.center_y = @begin_center_y + (e.realY - @origin.realY)
        @space.calculateBox()

    end: (e) ->
        begin =
            x: @begin_center_x
            y: @begin_center_y
        
        end   =
            x: @begin_center_x + (e.realX - @origin.realX)
            y: @begin_center_y + (e.realY - @origin.realY)
        
        {
            undo: (space) ->
                space.box.center_x = begin.x
                space.box.center_y = begin.y
            
            redo: (space) ->
                space.box.center_x = end.x
                space.box.center_y = end.y
        }

    draw: ->

class MakePointAction
    constructor: (@space, e) ->
        @beginPoint = {x: e.x, y: e.y}
    
    update: (e) ->
        if distance(e, @beginPoint) > Settings.point.create_distance
            return false
    
    end: (e) ->
        s = @space.snapGrid(e)
        pnt = new FreePoint(s.x, s.y)
        @space.attach pnt
        pnt.invalidate()

        {
            undo: -> pnt.destroy()
            redo: -> pnt.undestroy()
        }
        
    draw: ->
        
class MovePointAction
    constructor: (@space, @point) ->
        @beginPosition = {x: @point.x, y: @point.y}
        @lastEvent = {x: 0, y: 0, time: +new Date}
    
    update: (e) ->
        dt = +new Date - @lastEvent.time
        if dt > 100
            currentEvent = {x: e.realX, y: e.realY, time: +new Date}
            ds = distance(@lastEvent, currentEvent)
            @lastEvent = currentEvent
            @speed = ds/dt
            
        s = if @speed <= 0.05 then @space.snapGrid(e) else e

        @point.x = s.x
        @point.y = s.y
        
        @point.invalidate()
        
    end: (e) ->
        s = @space.snapGrid(e)
    
        @point.x = s.x
        @point.y = s.y

        bp = @beginPosition
        ep = {x: @point.x, y: @point.y}
        p = @point

        {
            undo: -> [p.x, p.y] = [bp.x, bp.y]
            redo: -> [p.x, p.y] = [ep.x, ep.y]
        }
    
    draw: ->

makeObjectMacro = (opts, fn=null) ->
    if not fn?
        fn = opts
        opts = {}

    opts.showHandle ?= false
    class
        constructor: (@space, @beginPoint) ->
            @freePoint  = new FreePoint @beginPoint.x, @beginPoint.y
            @objects    = fn @beginPoint, @freePoint
            @objects.push @freePoint if opts.showHandle

            object.forceCalculate() for object in @objects
            
        update: (e) ->
            {x, y} = @space.snapPoint(e)
            [@freePoint.x, @freePoint.y] = [x, y]

            object.forceCalculate() for object in @objects
            
        end: (e) ->
            object.destroy() for object in @objects

            if(endPoint = @space.nearestPoint e)
                for object in (objects = fn @beginPoint, endPoint)
                    object.invalidate()
                    object.forceCalculate()
                    @space.attach(object)

                {
                    undo: -> o.destroy()   for o in objects
                    redo: -> o.undestroy() for o in objects
                }
            else
                false   

        draw: (ctx) ->
            Draw.magic(ctx, @space, object) for object in @objects when not object.helper

MakeLineAction   = makeObjectMacro (a, b) -> [new Line(a, b)]

MakeCircleAction = makeObjectMacro (a, b) -> [new Circle(a, b)]

MakeEqTriangleAction = makeObjectMacro {showHandle: true}, (a, b) ->
    c1 = new Circle(a, b)
    c2 = new Circle(b, a)
    i  = new DependentPoint(c1, c2, 1)

    c1.helper = true
    c2.helper = true

    l1 = new Line(i, a)
    l2 = new Line(b, i)
    l3 = new Line(a, b)

    [c1, c2, i, l1, l2, l3]

MakePerpBisectAction = makeObjectMacro {showHandle: true}, (a, b) ->
    c1 = new Circle(a, b)
    c2 = new Circle(b, a)
    i1 = new DependentPoint(c1, c2, 0)
    i2 = new DependentPoint(c1, c2, 1)
    l = new Line(i1, i2)

    c1.helper = true
    c2.helper = true
    l.extended = true

    [c1, c2, i1, i2, l]

Tools =
    InteractTool: class
        constructor: (@space) ->
            @action = false

        mousedown: (e) ->
            return null if @action

            hit = false

            if (point = @space.nearestPoint(e)) then switch
                when e.button == 0 and point.free
                    @action = new MovePointAction(@space, point)
            else
                @action = new TranslateAction(@space, e)
        
        mousemove: (e) ->
            return null if not @action
            res = @action.update(e)
            
        mouseup: (e) ->
            return null if not @action

            if (action = @action.end(e))
                @space.history.push action
            
            @action = false
            
        draw: (ctx) ->
            @action.draw(ctx) if @action

    DefaultTool: class
        constructor: (@space) ->
            @selectionLine = null
            @action = false

        mousedown: (e) ->
            return null if @action

            hit = false
            @space.layers.tool.needsDraw = true

            if (point = @space.nearestPoint(e)) then switch
                when e.ctrlKey && e.button == 0 && point.free
                    @action = new MovePointAction(@space, point)
            
                # temp demo code
                when e.button == 0 and e.altKey
                    @action = new MakePerpBisectAction(@space, point)

                when e.button == 2 and e.altKey
                    @action = new MakeEqTriangleAction(@space, point)

                when e.button == 2 # right click
                    @action = new MakeCircleAction(@space, point)

                when e.button == 0
                    @action = new MakeLineAction(@space, point)
            
            else
                @action = new MakePointAction(@space, e)
        
        mousemove: (e) ->
            return null if not @action
            
            @space.layers.tool.needsDraw = true
            res = @action.update(e)

            if res == false and @action instanceof MakePointAction then switch
                when e.shiftKey
                    @action = new TranslateAction(@space, e)
                else
                    @action = new SelectionAction(@space, @action.beginPoint, {keep: e.ctrlKey})
            
        mouseup: (e) ->
            return null if not @action

            @space.layers.tool.needsDraw = true
            if (action = @action.end(e))
                @space.history.push action
            
            @action = null
            
        draw: (ctx) ->
            @action.draw(ctx) if @action

    ConstructTool: class
        constructor: (@space, {@inputs, @fn}) ->
            @inputPoints = []
            @inputPoints.push (@currentPoint = new FreePoint())
            @destroyed = false

        mousedown: (e) ->
            @space.layers.tool.needsDraw = true

            if (point = @space.nearestPoint(e))
                @inputPoints.pop()
                @inputPoints.push point

            if @inputPoints.length == @inputs
                for object in (objects = @fn.apply(null, @inputPoints))
                    object.invalidate()
                    object.forceCalculate()
                    @space.attach(object)

                @space.history.push {
                    undo: -> o.destroy()   for o in objects
                    redo: -> o.undestroy() for o in objects
                }

                @destroyed = true

            @inputPoints.push (@currentPoint = new FreePoint())

            if @inputPoints.length == @inputs
                @objects = @fn.apply(null, @inputPoints)
        
        mousemove: (e) ->
            @space.layers.tool.needsDraw = true

            {x, y} = @space.snapPoint(e)

            @currentPoint.x = x
            @currentPoint.y = y
            
        mouseup: (e) ->
            
        draw: (ctx) ->
            if @objects
                for object in @objects
                    object.forceCalculate()
                    Draw.magic ctx, @space, object
            else
                lastPoint = null
                for point in @inputPoints
                    if lastPoint?
                        Draw.line ctx, @space, {p1: point, p2: lastPoint}
                    Draw.point ctx, @space, point
                    lastPoint = point

globalize {Tools}
