shape_color = "#444"

Settings =
    point:
        draw_radius: 2.5
        hit_radius:  16
        hover_draw_radius: 10
        label_distance: 17
        create_distance: 6 # de afstand waarna de engine overgaat in selecte ipv puntmaken
    
        color: "#666"

        free:
            color: "#006cff"

        selected:
            color: "#006cff"

    shape:
        color: shape_color
        line_width: 1

        helper:
            color: shape_color
            line_width: 1/4

        selected:
            color: "#006cff"
            line_width: 1.5

    select:
        segment_length: 5
        segment_jmp: 33
        
    label:
        color: "#000"
        dx: 10
        dy: 0
        d: 7.5
        font_size: 11
        font_family: "sans-serif"
        
    listing:
        x: 5
        y: 5
        font_size: 12
        line_height: 1.33
    
    scale: 8
    
    zoom: pow(2, -(pow(2,7)-2))

    grid:
        lightness: 0.1
    
    color:
        light1: "#eee"
        light2: "#aaa"

    toolbar: [
        [{
            tool: "!std"
            name: "Hand"
        }]

        [{
            tool: "!interact"
            name: "~"
        }]

        [{
            tool: 'line'
            name: 'Lijn'
            icon: (ctx, box) ->
                p = 0.24
                Draw.point(ctx, box, {x: p, y: 1-p})
                Draw.point(ctx, box, {x: 1-p, y: p})
                Draw.line(ctx, box, {p1: {x: p, y: 1-p}, p2: {x: 1-p, y: p}})
        },{
            tool: 'line_extended'
            name: 'Lijn*'
            icon: (ctx, box) ->
                p = 0.24
                Draw.point(ctx, box, {x: p, y: 1-p})
                Draw.point(ctx, box, {x: 1-p, y: p})
                Draw.line(ctx, box, {p1: {x: 0, y: 1}, p2: {x: 1, y: 0}})
        }]

        [{
            tool: 'bisectrice'
            name: 'Bisectrice'
            icon: (ctx, box) ->
                p = 0.18

                a = {x: p, y: 1-p*2}
                b = {x: 1-p, y: p}
                c = {x: 1-p, y: 1-p}

                Draw.point(ctx, box, a)
                Draw.point(ctx, box, b)
                Draw.point(ctx, box, c)

                Draw.line(ctx, box, {p1: a, p2: b})
                Draw.line(ctx, box, {p1: a, p2: c})
        }]

        [{
            tool: 'loodlijn'
            name: 'Loodlijn'
            icon: (ctx, box) ->
                p = 0.18
                a = {x: p, y: 1-p*2}
                b = {x: 1-p, y: p*2}
                c = {x: p*2, y: p}
                Draw.point(ctx, box, a)
                Draw.point(ctx, box, b)
                Draw.point(ctx, box, c)
                Draw.line(ctx, box, {p1: a, p2: b})
                Draw.line(ctx, box, {p1: {x: p*2-p/2, y: 0}, p2: {x: 1-p*2+p/2, y: 1}})

        },{
            tool: 'middelloodlijn'
            name: 'Middelloodlijn'
            icon: (ctx, box) ->
                p = 0.18
                a = {x: p, y: 1-p*2}
                b = {x: 1-p, y: p*2}
                Draw.point(ctx, box, a)
                Draw.point(ctx, box, b)
                Draw.line(ctx, box, {p1: a, p2: b})
                Draw.line(ctx, box, {p1: {x: p*2, y: 0}, p2: {x: 1-p*2, y: 1}})
        }]

        [{
            tool: 'triangle'
            name: 'Driehoek'
        },{
            tool: 'square'
            name: 'Vierkant'
        }]

        [{
            tool: 'awesome_circles'
            name: 'Cirkels demo'
        },{
            tool: 'awesome_lines'
            name: 'Lijnen demo'
        }]
    ]

globalize {Settings}