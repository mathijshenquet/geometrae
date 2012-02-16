
class Gui
    constructor: (@space) ->
        @elements = [ new Listing(@space, {left: 0, right: 0, top: 40, bottom: 0})
                    , new Toolbar(@space, {left: 0, right: 0, top: 0 , bottom: 0})]
        
    draw: (ctx) ->
        for e in @elements
            e.draw(ctx)

class Toolbar
    constructor: (@space, @box) ->
    
    draw: (ctx) ->
        #@drawBox(ctx, {x: 0, y: 0, w: 36, h: 36})
    
        for tool in @space.tools
            selected = tool == @space.tool
            
    drawBox: (ctx, {x, y, w, h}) ->
        br = 5 # border radius
        r = x + w
        b = y + h
        l = x
        t = y
        
        ctx.strokeStyle = "#ccc"
        
        ctx.translate(0.5, 0.5)
        
        ctx.beginPath()
        
        ctx.moveTo(l+br, t)
        ctx.arcTo(r, t, r, b, br)
        ctx.arcTo(r, b, l, b, br)
        ctx.arcTo(l, b, l, t, br)
        ctx.arcTo(l, t, r, t, br)
        
        ctx.stroke()
        
        ctx.translate(-0.5, -0.5)

class Listing
    constructor: (@space, @box) ->

    draw: (ctx) ->
        #return null if EuclidesApp.listing == false
    
        box = {}
        for side of @box
            box[side] = @box[side] + @space.box[side]
    
        ctx.font = "#{Settings.listing.font_size}px monospace"
        ctx.textBaseline = "top"
        ctx.textAlign = "left"
        
        i = 0
        @space.points.forEach (point) ->
            pos = ""
            pos += pad 6, " ", (if not point.free then " = #{point.o1.name}∩#{point.o2.name}" else "")
            pos += " = " + Show.coords(point)
        
            ctx.fillText "#{point.name}#{pos}", 
                         box.right + Settings.listing.x, 
                         box.top + Settings.listing.y + i * Settings.listing.font_size * Settings.listing.line_height
        
        ctx.textAlign = "right"
        i = -1
        @space.shapes.forEach (object) ->
            i++
            combsign = if object instanceof Line then "—" else "○"
        
            ctx.fillText "#{object.name} = #{object.p1.name}#{combsign}#{object.p2.name}", 
                         box.left - Settings.listing.x, 
                         box.top + Settings.listing.y + i * Settings.listing.font_size * Settings.listing.line_height
        
globalize {Gui}
