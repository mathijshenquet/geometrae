
class Gui
    constructor: (@space) ->
        @listing = new Listing(@space, {left: 0, right: 0, top: 40, bottom: 0})
        @toolbar = new Toolbar(@space)
        @overlay = new Overlay(@space)
        
    draw: (ctx) ->
        @listing.draw(ctx)

    toggleHide: (name) -> @[name].toggleHide() if @[name]

    popup: (type, fn) -> @overlay.popup(type, fn)

class Overlay
    constructor: (@space) ->
        @$overlay = $ "<div class=overlay style=z-index:10;position:absolute;top:0;bottom:0;right:0;left:0>"
        @$popup = $ '<div class=dialog style=position:absolute;z-index:11;>'
        @$popup.hide()
        @space.element.append @$overlay
        @space.element.append @$popup

    close: ->
        @$popup.removeClass().addClass('dialog').hide()
        @interaction o

    interaction: (state) -> switch state
        when off then @$overlay.addClass("active").fadeTo(500, 0.5)
        when on  then @$overlay.fadeTo(500, 0, -> $(this).removeClass("active"))

    popup: (type, fn) -> switch type
        when 'dialog'
            @interaction off
            @$popup.addClass "dialog"
            fn.call this, @$popup
            @$popup.slideDown 500

class Toolbar
    constructor: (@space) ->
        @element = $("<div id=tools style=z-index:10;position:absolute;padding-top:13px;padding-left:3px;overflow:hidden;>")

        @space.element.append @element
        @focused_tool_element = null
        @hidden = false

        for group in Settings.toolbar
            if group == '---'
                @addSeperator()
                continue

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
    
    addSeperator: ->
        sep = $("<div class=tool_sep style=clear:left;width:#{Settings.toolbar.size}px>")
        @element.append sep

    toolElementFromTool = (tool) ->
        size = Settings.toolbar.size

        tool_element = $("<canvas class=tool title=\"#{tool.name}\" width=#{size} height=#{size} style=display:block;float:left>")

        ctx = tool_element[0].getContext('2d')

        gradient = ctx.createRadialGradient(size/2, size/2, 0, size/2, size/2, sqrt(pow(size,2)/2))
        gradient.addColorStop(1/8, "#fff")
        gradient.addColorStop(1, "#ccc")

        ctx.fillStyle = gradient
        ctx.fillRect(0, 0, size, size)

        tool.icon(ctx, { scale: size }) if tool.icon

        tool_element.mousedown (e) -> return false
        tool_element.mouseup (e) -> return false
        tool_element.click (e) =>
            $('.selected').removeClass('selected').fadeTo(500, 0.618)
            tool_element.addClass('selected')
            tool.fn()
            return false
        tool_element.fadeTo(0, 0.5)
        tool_element.hover (=>
                tool_element.stop().fadeTo(100, 0.9)
            ), (->
                tool_element.stop().fadeTo(500, 0.618) if not tool_element.hasClass('selected')
            )

        tool_element

    addGroup: (tools) ->
        group_element = $("<div style=clear:left;overflow:hidden;white-space:nowrap>")
        @element.append group_element

        tool_container = $ "<div>"
        group_element.append tool_container

        tools.forEach (tool) =>
            tool_container.append toolElementFromTool(tool)

        max_width = group_element.width()
        min_width = tool_container.children(':first').outerWidth(true)

        group_element.height group_element.height()
        group_element.width min_width

        tool_container.height tool_container.height()
        tool_container.width '3000px'

        tool_container.children(':first').mouseenter =>
            group_element.animate {width: max_width}, 180
        group_element.mouseleave =>
            group_element.animate {width: min_width}, 180

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
