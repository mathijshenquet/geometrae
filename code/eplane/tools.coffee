class LineSelectionAction
    constructor: (@space, e, opts={}) ->
        opts.keep ?= false

        @selectionLine = [e]
        @selectSegment = new Line (new FreePoint e.x, e.y, @space), (new FreePoint e.x, e.y, @space)
        @space.clearSelection() if not opts.keep
        
    update: (e) ->
        @mouse = e.relative
        
        @selectSegment.p2.x = @mouse.x
        @selectSegment.p2.y = @mouse.y
        @selectSegment.forceCalculate()
        
        return true if @selectSegment.length < (Settings.select.segment_length/@space.box.scale)
        
        @space.objects.filter((object) -> object.visible and not object.selected).forEach (object) =>
            intersection_object = if object.type == "Point"
                new Circle.raw(object.x, object.y, Settings.point.hit_radius/@space.box.scale)
            else
                object

            if Intersection.has(intersection_object, @selectSegment)
                @space.selectionAdd(object)

        if @selectSegment.length > (Settings.select.segment_jmp/@space.box.scale)
            @selectionLine.push {x: @mouse.x, y: @mouse.y}

            @selectSegment.p1.x = (@selectSegment.p1.x + @selectSegment.p2.x) / 2
            @selectSegment.p1.y = (@selectSegment.p1.y + @selectSegment.p2.y) / 2
            
    end: ->
    
    draw: (ctx) ->
        Draw.selectionLine(ctx, @space, @selectionLine, @mouse)

class BoxSelectionAction
    constructor: (@space, e, opts={}) ->
        opts.keep ?= false
        @space.clearSelection() if not opts.keep

        @selectionBox = 
            origin: new FreePoint e.x, e.y, @space
            target: new FreePoint e.x, e.y, @space
        
    update: (e) ->
        @mouse = e.relative
        
        @selectionBox.target.x = @mouse.x
        @selectionBox.target.y = @mouse.y
        
        @space.clearSelection()
        @space.objects.filter((object) -> object.visible).forEach (object) =>
            if object.boundedBy @selectionBox.origin, @selectionBox.target
                @space.selectionAdd(object)

    end: ->
    
    draw: (ctx) ->
        Draw.selectionBox ctx, @space, @selectionBox.origin, @selectionBox.target

class TranslateAction
    constructor: (@space, @origin) ->
        @begin_center_x = @space.box.center_x
        @begin_center_y = @space.box.center_y

    update: (e) ->
        @space.box.center_x = @begin_center_x + (e.absoluteX - @origin.absoluteX)
        @space.box.center_y = @begin_center_y + (e.absoluteY - @origin.absoluteY)
        @space.calculateBox()

    end: (e) ->
        begin =
            x: @begin_center_x
            y: @begin_center_y
        
        end   =
            x: @begin_center_x + (e.absoluteX - @origin.absoluteX)
            y: @begin_center_y + (e.absoluteY - @origin.absoluteY)
        
        {
            undo: (space) ->
                space.box.center_x = begin.x
                space.box.center_y = begin.y
            
            redo: (space) ->
                space.box.center_x = end.x
                space.box.center_y = end.y
        }

    draw: ->

class MouseZoomAction
    constructor: (@space, @origin, inverse) ->
        @i = 1
        @begin_scale = @space.box.scale
        @begin_center_x = @space.box.center_x
        @begin_center_y = @space.box.center_y

    update: (e) ->
        @space.box.center_x = @begin_center_x
        @space.box.center_y = @begin_center_y
        @space.box.scale    = @begin_scale

        @space.zoom @i*distance(@origin.absolute, e.absolute)/10, @origin.relative
        @space.calculateBox()

    end: (e) ->
        begin =
            x: @begin_center_x
            y: @begin_center_y
            scale: @begin_scale
        
        end   =
            x: @begin_center_x + (e.absoluteX - @origin.absoluteX)
            y: @begin_center_y + (e.absoluteY - @origin.absoluteY)
            scale: @space.box.scale
        
        {
            undo: (space) ->
                space.box.scale    = begin.scale
                space.box.center_x = begin.x
                space.box.center_y = begin.y
            
            redo: (space) ->
                space.box.scale    = end.scale
                space.box.center_x = end.x
                space.box.center_y = end.y
        }

    draw: ->

class MakePointAction
    constructor: (@space, e) ->
        @beginPoint = e.relative
    
    update: (e) ->
        if distance(e.relative, @beginPoint) > Settings.point.create_distance
            return false
    
    end: (e) ->
        s = @space.snapGrid(e.relative)
        pnt = new FreePoint(s.x, s.y, @space)
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
            currentEvent = {x: e.absoluteX, y: e.absoluteY, time: +new Date}
            ds = distance(@lastEvent, currentEvent)
            @lastEvent = currentEvent
            @speed = ds/dt
            
        s = if @speed <= 0.05 then @space.snapGrid e.relative else e.relative

        @point.x = s.x
        @point.y = s.y
        
        @point.invalidate()
        
    end: (e) ->
        s = @space.snapGrid e.relative
    
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
            @freePoint  = new FreePoint @beginPoint.x, @beginPoint.y, @space
            @objects    = fn @beginPoint, @freePoint
            @objects.push @freePoint if opts.showHandle

            object.forceCalculate() for object in @objects
            
        update: (e) ->
            {x, y} = @space.snapPoint e.relative
            [@freePoint.x, @freePoint.y] = [x, y]

            object.forceCalculate() for object in @objects
            
        end: (e) ->
            object.destroy() for object in @objects

            if(endPoint = @space.nearestPoint e.relative)
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

class ConstructAction
    constructor: (@space, {@inputs, @fn}, @tool) ->
        @inputPoints = []
        @createdPoints = []
        @currentPoint = new FreePoint(undefined, undefined, @space)

    finalize: ->
        objects = [].concat @createdPoints, @fn.apply(null, @inputPoints)

        objects.forEach (object) =>
            object.invalidate()
            object.forceCalculate()
            @space.attach(object)

        @space.history.push {
            undo: -> o.destroy()   for o in objects
            redo: -> o.undestroy() for o in objects
        }

        @tool.done()

    anchor: (point) ->
        if not point?
            @createdPoints.push @currentPoint
            point = @currentPoint
    
        @inputPoints.push point

        if @inputs == @inputPoints.length
            return @finalize()
        
        @currentPoint = new FreePoint(undefined, undefined, @space)

        if @inputs == @inputPoints.length + 1
            @objects = [].concat @fn.apply(null, @inputPoints.concat [@currentPoint]), @createdPoints.concat [@currentPoint]

    update: (e) ->
        {x, y} = @space.snapPoint(e)

        @currentPoint.x = x
        @currentPoint.y = y
        
    draw: (ctx) ->
        if @objects
            for object in @objects
                object.forceCalculate()
                Draw.magic ctx, @space, object
        else
            lastPoint = null
            for point in @inputPoints.concat(@currentPoint)
                if lastPoint?
                    Draw.line ctx, @space, {p1: point, p2: lastPoint}
                Draw.point ctx, @space, point
                lastPoint = point

Tools =
    DefaultTool: class DefaultTool
        constructor: (@space) ->
            @selectionLine = null
            @action = false

        mousedown: (e) ->
            return null if @action

            hit = false
            @space.layers.tool.needsDraw = true

            if (point = @space.nearestPoint e.relative) then switch
                when point.free and Settings.default_tool.move_point(e)
                    @action = new MovePointAction(@space, point)

                when Settings.default_tool.make_circle(e)
                    @action = new MakeCircleAction(@space, point)

                when Settings.default_tool.make_line(e)
                    @action = new MakeLineAction(@space, point)
            
            else
                @action = new MakePointAction(@space, e)
        
        mousemove: (e) ->
            return null if not @action
            
            @space.layers.tool.needsDraw = true
            res = @action.update(e)

            if res == false and @action instanceof MakePointAction then switch
                when Settings.default_tool.translate(e)
                    @action = new TranslateAction     @space, e
                when Settings.default_tool.line_select(e)
                    @action = new LineSelectionAction @space, @action.beginPoint, {keep: Settings.default_tool.helper(e, {mod: true})}
                when Settings.default_tool.box_select(e) 
                    @action = new BoxSelectionAction  @space, @action.beginPoint, {keep: Settings.default_tool.helper(e, {mod: true})}
            
        mouseup: (e) ->
            return null if not @action

            @space.layers.tool.needsDraw = true
            if (action = @action.end(e))
                @space.history.push action
            
            @action = null
        
        touchstart: (e) ->
            hit = false
            @space.layers.tool.needsDraw = true

            for touch in e.touches
                for prop, value of touch
                    alert "#{prop} = #{value}"

            if (point = @space.nearestPoint(e.touches[0]))
                @action = {beginPoint: point, action: "on_point"}
            
            else
                @action = new MakePointAction(@space, e.touches[0])

        touchmove: (e) ->
            return null if not @action

        touchend: (e) ->
            return null if not @action

            if (action = @action.end(e.touches[0]))
                @space.history.push action

            @action = null

        draw: (ctx) ->
            @action.draw(ctx) if @action

    InteractTool: class InteractTool
        constructor: (@space) ->
            @action = false

        mousedown: (e) ->
            return null if @action

            hit = false

            if (point = @space.nearestPoint e.relative) and e.button == 0 and point.free
                @action = new MovePointAction(@space, point)
            
            else if e.button == 0
                @action = new TranslateAction(@space, e)

            else if e.button == 2
                @action = new MouseZoomAction(@space, e, e.shiftKey)
        
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

    ConstructTool: class ConstructTool
        constructor: (@space, @constructionData) ->
            @beginConstruction()
            @baseTool = new DefaultTool(@space)

        beginConstruction: ->
            @action = new ConstructAction(@space, @constructionData, this)

        done: -> @beginConstruction()

        mousedown: (e) ->
            if e.ctrlKey or e.shiftKey or e.altKey
                return @baseTool.mousedown(e)

            @space.layers.tool.needsDraw = true

            if (point = @space.nearestPoint e.relative)
                @action.anchor(point)
            else
                @action.anchor()

            @lastMouseDown = e
        
        mousemove: (e) ->
            if @baseTool.action
                @baseTool.mousemove(e)

            @space.layers.tool.needsDraw = true

            @action.update(e.relative)
            
        mouseup: (e) ->
            if @baseTool.action
                return @baseTool.mouseup(e)

            if distance(e.absolute, @lastMouseDown.absolute) > Settings.point.draw_radius
                @space.layers.tool.needsDraw = true
                if (point = @space.nearestPoint(e.relative))
                    @action.anchor(point)
                else
                    @action.anchor()

        draw: (ctx) ->
            @action.draw(ctx)
            @baseTool.draw(ctx)

globalize {Tools}
