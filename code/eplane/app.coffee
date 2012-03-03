processEvent = (e, box) ->
    if TouchEvent? and e instanceof TouchEvent
        processEvent(touch, box) for touch in e.touches
        processEvent(touch, box) for touch in e.changedTouches
        processEvent(touch, box) for touch in e.targetTouches
        return e

    absoluteX = (e.pageX ? e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft) - box.offsetLeft
    relativeX = (absoluteX - box.center_x)/box.scale
    
    absoluteY = (e.pageY ? e.clientY + document.body.scrollTop + document.documentElement.scrollTop) - box.offsetTop
    relativeY = (absoluteY - box.center_y)/box.scale

    e.absoluteX = absoluteX
    e.absoluteY = absoluteY
    e.relativeX = relativeX
    e.relativeY = relativeY

    e.absolute = {x: absoluteX, y: absoluteY}
    e.relative = {x: relativeX, y: relativeY}

    return e

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
        @box.scale = Settings.box.zoom
        
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

        bind = (type, handler) => @element[0].addEventListener type, handler

        if BrowserDetect.OS == "iPad"        
            bind 'touchstart', (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.touchstart(e) if @tool.touchstart?

            bind 'touchmove', (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.touchmove(e) if @tool.touchmove?

            bind 'touchend', (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.touchend(e) if @tool.touchend?

        else
            bind "mousedown", (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.mousedown(e)
                
            bind "mousemove", (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.mousemove(e)
                @hover(e)
            
            bind "mouseup", (e) =>
                e.preventDefault()
                e = processEvent(e, @box)
                @tool.mouseup(e)
        
            @element.mousewheel (e, delta) =>
                e.preventDefault()
                processEvent(e, @box)
                @zoom delta, @snapPoint(e.relative)

        $(document)
            .jkey Settings.keybindings.cancel_constr, =>
                @selectTool 'std'

            .jkey Settings.keybindings.select_all, =>
                @clearSelection()
                @objects.filter((object) -> object.visible).forEach (object) =>
                    object.selected = true
                    @selectionAdd(object)

            .jkey Settings.keybindings.undo, =>
                @history.undo()

            .jkey Settings.keybindings.redo, => 
                @history.redo()

            .jkey Settings.keybindings.extend, true, =>
                targetObjects = [].concat @selection
                targetState = targetObjects.some (object) -> object.extended

                (object.extended = not object.extended) for object in @selection
                        
            .jkey Settings.keybindings.hide, true, =>
                targetObjects = [].concat @selection

                @history.push {
                    undo: ->
                        object.hidden = false for object in targetObjects
                    redo: ->
                        object.hidden = true for object in targetObjects
                }

                object.hidden = true for object in @selection

                @clearSelection()
                    
            .jkey Settings.keybindings.destroy, true, =>
                targetObjects = []
                targetObjects = targetObjects.concat @selection
                object.destroy() for object in targetObjects

                @layers.objects.needsDraw = true

                @history.push {
                    undo: ->
                        object.undestroy() for object in targetObjects
                    redo: ->
                        object.destroy() for object in targetObjects
                }

                @clearSelection()
                
            .jkey Settings.keybindings.show_grid, (args...) =>
                @grid = not @grid
                @layers.background.needsDraw = true
      
            .jkey Settings.keybindings.snap_grid, true, () =>
                @snap = not @snap

            .jkey Settings.keybindings.show_listing, true, =>
                @listing = not @listing
                            
            .jkey Settings.keybindings.clear_selection, true, =>
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

    zoom: (delta, p) ->
        s0 = @box.scale
        s1 = (@box.scale += delta/10 * @box.scale)
        ds = s1/s0

        @box.center_x -= round (p.x * s0 * (ds - 1))
        @box.center_y -= round (p.y * s0 * (ds - 1))

        @layers.background.needsDraw = true
        @layers.objects.needsDraw = true
        @calculateBox()

    selectTool: (name, fn=null) ->
        @layers.tool.needsDraw = true

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
            continue if @objects.some((o) -> o == object)

            object.forceCalculate()

            pred = (other) ->
                other.type == object.type and
                other != object           and
                other.visible             and
                other.equal(object)

            object.hidden = true if @objects.some(pred)

            @objects.push object

            switch object.type
                when 'Line'
                    @lines.push   object
                    @shapes.push  object
                when 'Circle'
                    @circles.push object
                    @shapes.push  object
                when 'Point'
                    @points.push  object

            continue if object.helper

            switch
                when object.type == 'Point'
                    object.name ?= @getPointName()
              
                when object.type == 'Line' or object.type == 'Circle'
                    #look if there is an object allready present constructed with the same points
                    if object.p1 == object.p2
                        object.destroy()
                        continue

                    @shapes.filter((object) -> not object.destroyed and not object.helper).forEach (other) =>
                        @addIntersections(other, object, false)
            
                    object.name ?= @getObjectName()
  
    nearestPoint: (location, limit=Settings.point.hit_radius/@box.scale) ->
        nearestPoint = null
        nearestDistance = limit
        @points.filter((point) -> point.visible).forEach (point) ->
            # When two point occupy praticly the same location, favour the first to itterate!
            return null unless (_ = distance(location, point)) < (nearestDistance * 0.99) 
            nearestPoint = point
            nearestDistance = _
            
        if nearestDistance < limit
            nearestPoint
        else
            false
  
    snapPoint: (point) -> @nearestPoint(point) or point
        
    snapGrid: ({x, y}) ->
        return {x, y} if not @snap

        q = log(@box.scale)/log(Settings.grid.scale)
        q += 0.25
        res = floor q

        s = (Settings.grid.scale * pow(Settings.grid.scale, -res))
        return {x: (s * (round x / s)), y: (s * (round y / s))}
        
    hover: (e, r) ->
        lastHover = @points.filter((point) -> point.hover)[0] ? false
        currentHover = @nearestPoint e.relative

        if lastHover != currentHover
            @layers.objects.needsDraw = true
            if lastHover then lastHover.hover = false
            if currentHover then currentHover.hover = true

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

        @box.translate_x = @box.center_x + .5
        @box.translate_y = @box.center_y + .5

        @box.offsetTop = @element[0].offsetTop
        @box.offsetLeft = @element[0].offsetLeft

        @layers[name].needsDraw = true for name of @layers

    centerBox: ->
        @box.center_x = floor (@box.width  * 0.5) # 0.382
        @box.center_y = floor (@box.height * 0.5) # 0.618

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
            objectsToUpdate.forEach (obj) -> obj.forceCalculate()
            @layers.objects.needsDraw = true

    draw: ->
        for layer_name of @layers
            layer = @layers[layer_name]

            if layer.needsDraw
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
