processEvent = (e, box) ->
    x = null
    x ?= e?.pageX
    x ?= e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
    x -= box.offsetLeft

    e.realX = x
    e.x = (x - box.center_x)/box.scale
    
    y = null
    y ?= e?.pageY
    y ?= e.clientY + document.body.scrollTop + document.documentElement.scrollTop
    y -= box.offsetTop

    e.realY = y
    e.y = (y - box.center_y)/box.scale

class EuclidesApp    
    shouldCullPoint: (point) -> not (@box.left < (point.x * @box.scale) < @box.right and @box.top < (point.y * @box.scale) < @box.bottom)

    toCanvasCoords: ({x, y}) -> {x: (x - @box.center_x) / @box.scale, y: (y - @box.center_y) / @box.scale}

    getName: (n, A, f=1) ->
        al = A.length
        
        digit = A[n%al]
        
        if n < al
            return digit
        else
            return @getName(floor(n/al)-f, A, 0) + digit
            
    pointAlphabet = (String.fromCharCode(n) for n in [65..90])
    
    objectAlphabet = (String.fromCharCode(n) for n in [97..122])
            
    getPointName: -> @getName(@pointNameIndex++, pointAlphabet)
    
    getObjectName: -> @getName(@objectNameIndex++, objectAlphabet)

    addLayer: (depth, name) ->
        canvas = $("<canvas style=position:absolute;z-index:#{depth} />")
        ctx = canvas[0].getContext('2d')
        needsDraw = true
        @element.append canvas
        @layers[name] = {canvas, ctx, needsDraw, hidden: false}

    toggleHide: (name) -> switch name
            when 'toolbar' then @gui.toggleHide('toolbar')
            else (@layers[name].hidden = not @layers[name].hidden) if @layers[name]?

    resize: ->
        width  = @element.width()
        height = @element.height()

        for name of @layers
            layer = @layers[name]
            layer.canvas[0].width  = width
            layer.canvas[0].height = height
            layer.needsDraw = true

        @calculateBox()

    @attr "snap"
        set: (v) -> @_snap = v
        get: -> @grid and @_snap

    constructor: (@element) ->
        @layers = {}

        @addLayer 0, 'background'
        @addLayer 1, 'objects'
        @addLayer 2, 'tool'

        @grid = true
        @labels = true
        @listing = false
        @snap = true

        @box = {}
        @box.scale = Settings.zoom
        
        @objects = []
        @points  = []
        @lines   = []
        @circles = []
        @shapes  = []
        
        @selection = []

        space = this
        @history = do ->
            state     = -1
            changes   = []
            hasFuture = false

            push    = (action) ->
                if hasFuture
                    changes   = changes.slice(0, state+1)
                    hasFuture = false

                changes.push action
                state  += 1

            undo    = ->
                return false if state < 0
                
                changes[state].undo(space)
                hasFuture = true
                state    -= 1

                space.layers[name].needsDraw = true for name of space.layers

            redo    = ->
                return false if not hasFuture

                changes[state+1].redo(space)
                state      += 1
                hasFuture   = changes[state+1]?

                space.layers[name].needsDraw = true for name of space.layers

            {push, undo, redo}

        @element.mousedown (e) =>
            e.preventDefault()
            processEvent(e, @box)
            @tool.mousedown(e)
            
        @element.mousemove (e) =>
            e.preventDefault()
            processEvent(e, @box)
            @tool.mousemove(e)
            @hover(e)
        
        @element.mouseup (e) =>
            e.preventDefault()
            processEvent(e, @box)
            @tool.mouseup(e)
    
        @element.mousewheel (e, delta) =>
            e.preventDefault()
            processEvent(e, @box)
            p = @snapPoint(e)

            s0 = @box.scale
            s1 = (@box.scale += delta/10 * @box.scale)
            ds = s1/s0

            @box.center_x -= p.x * s0 * (ds - 1)
            @box.center_y -= p.y * s0 * (ds - 1)

            @layers.background.needsDraw = true
            @layers.objects.needsDraw = true
            @calculateBox()

        $(document)
            .jkey 'ctrl+a', =>
                @clearSelection()
                @objects.filter((object) -> object.visible).forEach (object) =>
                    object.selected = true
                    @selectionAdd(object)

            .jkey 'ctrl+z', => 
                @history.undo()

            .jkey 'ctrl+y', => 
                @history.redo()

            .jkey 'x', true, =>
                targetObjects = [].concat @selection
                targetState = targetObjects.some (object) -> object.extended

                (object.extended = not object.extended) for object in @selection
                        
            .jkey 'h', true, =>
                targetObjects = [].concat @selection

                @history.push {
                    undo: ->
                        object.hidden = false for object in targetObjects
                    redo: ->
                        object.hidden = true for object in targetObjects
                }

                object.hidden = true for object in @selection

                @clearSelection()
                    
            .jkey 'd', true, =>
                targetObjects = []
                targetObjects = targetObjects.concat @selection
                targetObjects = targetObjects.concat @points.filter((point) -> point.visible and point.free and point.children.length == 0)
                object.destroy() for object in targetObjects

                @layers.objects.needsDraw = true

                @history.push {
                    undo: ->
                        object.undestroy() for object in targetObjects
                    redo: ->
                        object.destroy() for object in targetObjects
                }

                @clearSelection()
                
            .jkey 'g', true, =>
                @grid = not @grid
                @layers.background.needsDraw = true
            
            .jkey 's', true, =>
                @snap = not @snap

            .jkey 'l', true, =>
                @listing = not @listing
                            
            .jkey 'space', true, =>
                @clearSelection()
            
        @element.bind "contextmenu", (e) -> e.preventDefault()
        
        @gui = new Gui(this)
    
        @tools =
            std: Tools.DefaultTool
            interact: Tools.InteractTool
            construct: Tools.ConstructTool

        @selectTool 'std'
        
        @pointNameIndex = 0
        @objectNameIndex = 0
        
        @resize()
        @centerBox()

        @enterLoop()

    selectTool: (name, fn=null) ->
        if fn instanceof Function
            opts = {fn, inputs: fn.length}

        opts ?= {}

        @tool = new @tools[name](this, opts)

    gc: ->
        for name in ['objects','points','lines','circles','shapes'] 
            @[name] = @[name].filter (obj) -> not obj.destroyed

    attach: (objects) ->
        @layers.objects.needsDraw = true

        if not (objects instanceof Array)
            objects = [objects]

        for object in objects
            type = switch
                when object instanceof Line       then 'line'
                when object instanceof Circle     then 'circle'
                when object instanceof Point      then 'point'
            
            @objects.push object

            switch type
                when 'line'   then @lines.push   object
                when 'circle' then @circles.push object
                when 'point'  then @points.push  object

            return null if object.helper

            switch
                when type == 'point'
                    object.forceCalculate()
                    {o1, o2} = object
                    
                    if o2 instanceof Line
                        [o1, o2] = [o2, o1]
                    
                    if o1 instanceof Line
                        if o2 instanceof Line
                            [l1, l2] = [o1, o2]
                            if l1.p1.laysOn l2 or l1.p2.laysOn l2 or l2.p1.laysOn l1 or l2.p2.laysOn l1 then return null 

                        #else if o2 instanceof Circle
                        #   return null if o1.p1.laysOn o2 or o1.p2.laysOn o2
                    
                    #overlaps = false
                    #@each {from: 'points'}, (point) ->
                    #    if point.sameRoots(new_point)
                    #        dist = distance(point, new_point)
                    #        if dist < sml
                    #            overlaps = true
                    #            return false
                    #return null if overlaps

                    object.name ?= @getPointName()
              
                when type == 'line' or type == 'circle'
                    return null if object.p1 == object.p2

                    @shapes.filter((object) -> not object.destroyed).forEach (other) =>
                        @addIntersections(other, object, false)
            
                    object.name ?= @getObjectName()
                    
                    @shapes.push object
  
    nearestPoint: (event, limit=Settings.point.hit_radius/@box.scale) ->
        nearestPoint = null
        nearestDistance = limit
        @points.filter((point) -> point.visible).forEach (point) ->
            # When two point occupy praticly the same location, favour the first to itterate!
            return null unless (_ = distance(event, point)) < (nearestDistance * 0.99) 
            nearestPoint = point
            nearestDistance = _
            
        if nearestDistance < limit
            nearestPoint
        else
            false
  
    snapPoint: (point) -> @nearestPoint(point) or point
        
    snapGrid: ({x, y}) ->
        return {x, y} if not @snap

        q = log(@box.scale)/log(Settings.scale)
        q += 0.25
        res = floor q

        s = (Settings.scale * pow(Settings.scale, -res))
        return {x: (s * (round x / s)), y: (s * (round y / s))}
        
    hover: (e, r) ->
        if (currentlyHovering = @points.filter((point) -> point.hover)).length != 0
            @layers.objects.needsDraw = true
            currentlyHovering.forEach (point) -> point.hover = false

        if(hoverPoint = @nearestPoint e)
            @layers.objects.needsDraw = true
            hoverPoint.hover = true

    selectionAdd: (object) ->
        @selection.push object
        object.selected = true
        @layers.objects.needsDraw = true

    clearSelection: ->
        for object in @selection
            object.selected = false

        @selection = []
        @layers.objects.needsDraw = true
        
    getPointFromName: (search_name) ->
        pnts = @points.filter((point) -> point.name == search_name)
        pnts[0] ? false
        
    addIntersections: (a, b, cull=false) ->
        {count} = Intersection.info(a, b)
        for i in [0...count]
            @attach new DependentPoint(a, b, i)

    calculateBox: ->
        @box.width   = @element.width()
        @box.height  = @element.height()
        
        @box.left    = -@box.center_x
        @box.right   = -@box.center_x + @box.width
        
        @box.top     = -@box.center_y
        @box.bottom  = -@box.center_y + @box.height

        @box.translate_x = floor(@box.center_x) + .5
        @box.translate_y = floor(@box.center_y) + .5

        @box.offsetTop = @element[0].offsetTop
        @box.offsetLeft = @element[0].offsetLeft

        @layers[name].needsDraw = true for name of @layers

    centerBox: ->
        @box.center_x = @box.width  * 0.5 # 0.382
        @box.center_y = @box.height * 0.5 # 0.618

        @calculateBox()

    enterLoop: ->
        fnUpdate = =>
            @update()
            setTimeout fnUpdate, 10
        fnUpdate()

        fnDraw = =>
            @draw()
            requestAnimationFrame fnDraw
        fnDraw()

    update: ->
        if (objectsToUpdate = @objects.filter (obj) -> obj.needsUpdate).length != 0
            @layers.objects.needsDraw = true
            objectsToUpdate.forEach (obj) -> obj.forceCalculate()

    draw: ->
        for layer_name of @layers
            layer = @layers[layer_name]

            if layer.needsDraw
                console.log "Draw #{layer_name}"

                layer.needsDraw = false

                layer.ctx.save()
                layer.ctx.clearRect 0, 0, @box.width, @box.height
                layer.ctx.translate @box.translate_x, @box.translate_y

                @draws[layer_name].call(this, layer.ctx) if not layer.hidden

                layer.ctx.restore()

    draws:
        background: (ctx) ->
            Draw.bgGrid ctx, this if @grid

        objects: (ctx) ->
            Draw.lines   ctx, this, @lines.filter((object) -> object.visible)
            Draw.circles ctx, this, @circles.filter((object) -> object.visible)
            Draw.points  ctx, this, @points.filter((object) -> object.visible)

        tool: (ctx) ->
            if @tool.destroyed
                @selectTool('std')

            @tool.draw ctx, this

        
globalize {EuclidesApp}
