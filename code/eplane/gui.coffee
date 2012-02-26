
class Gui
    constructor: (@space) ->
        @listing = new Listing(@space, {left: 0, right: 0, top: 40, bottom: 0})
        @toolbar = new Toolbar(@space)
        
    draw: (ctx) ->
        @listing.draw(ctx)

    toggleHide: (name) -> @[name].toggleHide() if @[name]

class Toolbar
    constructor: (@space) ->
        @element = $("<div id=tools style=z-index:10>")
        @space.element.append @element

        @hidden = false

        for group in Settings.toolbar
            for tool in group
                do (tool) =>
                    if (isRootTool = tool.tool[0] == '!')
                        tool.id = tool.tool[1..]
                        tool.fn = => @space.selectTool tool.id
                    else
                        tool.id = tool.tool
                        tool.fn = => @space.selectTool 'construct', Constructions[tool.id]

            @addGroup group

    toggleHide: ->
        @hidden = not @hidden
        @element.hide()
    
    addGroup: (tools) ->
        group_element = $("<ul id=#{name}>")
        @element.append group_element

        tools.forEach (tool) ->
            tool_element = $("<li class=tool_#{tool.id} title=\"#{tool.name}\"></li>")

            icon = $('<canvas width=32 height=32>')
            tool_element.append icon

            ctx = icon[0].getContext('2d')
            box = { scale: 32 }
            tool.icon(ctx, box) if tool.icon

            tool_element.mousedown (e) -> return false

            tool_element.mouseup (e) -> return false

            tool_element.click (e) ->
                tool.fn()
                e.stopPropagation()
                return false

            tool_element.fadeTo(0, 0.5)

            tool_element.hover (->
                    tool_element.stop().fadeTo(100, 0.9)
                ), (->
                    tool_element.stop().fadeTo(500, 0.618)
                )

            group_element.append tool_element

class Listing
    constructor: (@space, @box) ->

    draw: (ctx) ->
        #return null if @listing == false
    
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
