mouse = {}

processEvent = (e, box) ->
	x = null
	x ?= e?.pageX
	x ?= e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
	x -= e.target.offsetLeft
	mouse.x = e.x = (x - box.center_x)/box.scale
	
	y = null
	y ?= e?.pageY
	y ?= e.clientY + document.body.scrollTop + document.documentElement.scrollTop
	y -= e.target.offsetTop
	mouse.y = e.y = (y - box.center_y)/box.scale

class EuclidesApp
	@grid = grid = false
	@labels = labels = true
	@listing = false
	
	shouldCullPoint: (point) -> not (@box.left < (point.x * @box.scale) < @box.right and @box.top < (point.y * @box.scale) < @box.bottom)

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

	constructor: (@canvas) ->
		@ctx = @canvas[0].getContext("2d")

		@box = {}
		@box.scale    = 1
		@calculateBox()
		@centerBox()
		
		@objects = []
		@points  = []
		@lines   = []
		@circles = []
		@shapes  = []
		
		@selection = []
		
		@canvas.mousedown (e) =>
			e.preventDefault()
			@mousedown(e)
			
		@canvas.mousemove (e) =>
			e.preventDefault()
			@mousemove(e)
		
		@canvas.mouseup (e) =>
			e.preventDefault()
			@mouseup(e)
	
		@canvas.mousewheel (e, delta) =>
			e.preventDefault()
			processEvent(e, @box)
			p = @snapPoint(e)

			s0 = @box.scale
			s1 = (@box.scale += delta/10 * @box.scale)
			ds = s1/s0

			@box.center_x -= p.x * s0 * (ds - 1)
			@box.center_y -= p.y * s0 * (ds - 1)

		@keyevents()
			
		@canvas.bind "contextmenu", (e) -> e.preventDefault()
		
		@gui = new Gui(this)
	
		@tools = [new DefaultTool(this)]
		@tool = @tools[0]
		
		@pointNameIndex = 0
		@objectNameIndex = 0
		  
		@drawLoop()

	gc: ->
		for name of @collections 
			@collections[name] = @collections[name].filter (obj) -> not obj.destroyed

	attach: (object, name) ->
		type = switch
			when object instanceof Line       then 'line'
			when object instanceof Circle     then 'circle'
			when object instanceof Point      then 'point'
			when object instanceof FreePoint  then 'point'
		
		@objects.push object

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
					#	return null if o1.p1.laysOn o2 or o1.p2.laysOn o2
				
				#overlaps = false
				#@each {from: 'points'}, (point) ->
				#    if point.sameRoots(new_point)
				#        dist = distance(point, new_point)
				#        if dist < sml
				#            overlaps = true
				#            return false
				#return null if overlaps
			 
				name ?= @getPointName()
				object.name = name
				@points.push object
		  
			when type == 'line' or type == 'circle'
				@shapes.forEach (other) =>
					@addIntersections(other, object, false)
		
				object.name = name ? @getObjectName()
		
				(switch type
					when 'line' then @lines
					when 'circle' then @circles).push object
				@shapes.push object
  
	nearestPoint: (event, limit=Settings.point.hit_radius/@box.scale) ->
		nearestPoint = null
		nearestDistance = limit
		@points.filter((point) -> point.visible).forEach (point) ->
			# When two point occupy praticly the same location, favour the first to itterate!
			return null unless (_ = distance(event, point)) < (nearestDistance - sml) 
			nearestPoint = point
			nearestDistance = _
			
		if nearestDistance < limit
			nearestPoint
		else
			false
  
	snapPoint: (point) -> @nearestPoint(point) or point
		
	snapGrid: ({x, y}) ->
		return {x, y} if not EuclidesApp.grid
		
		s = Settings.scale
		return {x: (s * round x / s), y: (s * round y / s)}
		
	hover: (e, r) ->
		@points.forEach (point) -> point.hover = false

		if(hoverPoint = @nearestPoint e)
			hoverPoint.hover = true
		
	mousedown: (e) ->
		processEvent(e, @box)
		@tool.mousedown(e)
	
	mousemove: (e) ->
		processEvent(e, @box)
		@tool.mousemove(e)
		@hover(e)
		
	mouseup: (e) ->
		processEvent(e, @box)
		@tool.mouseup(e)
		
	keyevents: ->
		$(document)
			.jkey 'x', =>
				for object in @selection
					object.extended = not object.extended
				
			#.jkey 'i', =>
			#    for own a, n in @selection
			#        for own b in @selection[(n+1)...@selection.length]
			#            @addIntersections(a, b)
						
			.jkey 'h', =>
				for object in @selection
					object.state.hidden = not object.state.hidden
					
			.jkey 'd', =>
				@selection.forEach (object) -> object.destroy()
				
				@points.filter((point) -> point.visible).forEach (point) ->
					if point.free and point.children.length == 0
						point.destroy()
				
			.jkey 'g', =>
				EuclidesApp.grid = not EuclidesApp.grid
				
			.jkey 'l', =>
				EuclidesApp.listing = not EuclidesApp.listing
							
			.jkey 'space', =>
				@clearSelection()

	clearSelection: ->
		for object in @selection
			object.selected = false

		@selection = []
		
	getPointFromName: (search_name) ->
		pnts = @points.filter((point) -> point.name == search_name)
		pnts[0] ? false
		
	addIntersections: (a, b, cull=false) ->
		for i in [0...Intersection.count(Intersection.mode(a, b))]
			@attach new Point(a, b, i)

	drawLoop: ->
		fn = =>
			@draw()
			requestAnimationFrame fn
		fn()

	calculateBox: ->
		@box.width   = @ctx.canvas.width
		@box.height  = @ctx.canvas.height
		
		@box.left    = -@box.center_x
		@box.right   = -@box.center_x + @box.width
		
		@box.top     = -@box.center_y
		@box.bottom  = -@box.center_y + @box.height

		@box.translate_x = floor(@box.center_x) + .5
		@box.translate_y = floor(@box.center_y) + .5

	centerBox: ->
		@box.center_x = @box.width/2
		@box.center_y = @box.height/2

	draw: ->
		@objects.forEach (obj) -> obj.forceCalculate()

		@calculateBox()

		@ctx.save()
		@ctx.clearRect(0, 0, @ctx.canvas.width, @ctx.canvas.height)
		
		@ctx.translate @box.translate_x, @box.translate_y
		
		Draw.bgGrid  @ctx, this if EuclidesApp.grid
		Draw.lines   @ctx, this, @lines.filter((object) -> object.visible)
		Draw.circles @ctx, this, @circles.filter((object) -> object.visible)
		Draw.points  @ctx, this, @points.filter((object) -> object.visible)
		
		@tool.draw(@ctx)
		@gui.draw(@ctx)
		
		@ctx.restore()
		
globalize {EuclidesApp}
