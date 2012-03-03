shape_color = "#444"



Settings = {}
    
Settings.point =
    draw_radius: 2.5
    hit_radius:  16
    hover_draw_radius: 10
    label_distance: 12
    create_distance: 6 # de afstand waarna de engine overgaat in selecte ipv puntmaken

    color: "#666"

    free:
        color: "#006cff"

    selected:
        color: "#006cff"

Settings.shape =
    color: shape_color
    line_width: 1

    helper:
        color: shape_color
        line_width: 1/4

    selected:
        color: "#006cff"
        line_width: 1

Settings.select =
    segment_length: 5
    segment_jmp: 33
        
Settings.label =
    color: "#000"
    dx: 10
    dy: 0
    d: 7.5
    font_size: 11
    font_family: "sans-serif"
        
Settings.listing =
    x: 5
    y: 5
    font_size: 12
    line_height: 1.33
    
Settings.box =
    zoom: pow(2, -(pow(2,7)-2))

Settings.grid =
    scale: 8
    lightness:  0.1
    axis:       "#aaa"

mod1 = if BrowserDetect.OS == 'Mac' then 'super' else 'ctrl'
Settings.keybindings =
    cancel_constr:  "esc"   
    select_all:     "#{mod1}+a"
    undo:           "#{mod1}+z"
    redo:           "#{mod1}+y"
    extend:         "x"
    hide:           "h"
    destroy:        "d, delete"
    show_grid:      "#{mod1}+g"
    snap_grid:      "g"
    show_listing:   "l"
    clear_selection:"space"

LEFT = 0
MIDDLE = 1
RIGHT = 2
helper = (e, opts={}) ->
    opts.mod    ?= false
    opts.shift  ?= false
    opts.alt    ?= false
    opts.other  ?= '~'

    [modKey, otherKey] = ['ctrlKey', 'metaKey']
    if BrowserDetect.OS == 'Mac'
        [modKey, otherKey] = [otherKey, modKey]

    mapping = [
        {opt: 'mod',    key: modKey}
        {opt: 'other',  key: otherKey}
        {opt: 'alt',    key: 'altKey'}
        {opt: 'shift',  key: 'shiftKey'}
    ]

    mapping.every (map) -> opts[map.opt] == '~' or e[map.key] == opts[map.opt]

Settings.default_tool =
    helper: helper
    move_point:     (e) -> helper(e, {mod: true}) and e.button == LEFT
    make_circle:    (e) -> helper(e) and (if BrowserDetect.OS == 'Mac' then (e.button == LEFT and e.ctrlKey) else false) or e.button == RIGHT
    make_line:      (e) -> helper(e) and e.button == LEFT
    translate:      (e) -> helper(e, {shift: true}) and e.button == LEFT
    box_select:     (e) -> helper(e) and (if BrowserDetect.OS == 'Mac' then (e.button == LEFT and e.ctrlKey) else false) or e.button == RIGHT
    line_select:    (e) -> helper(e)

Settings.toolbar = [
    [{
        tool: "!std"
        name: "Hand"
    }]

    [{
        tool: "!interact"
        name: "~"
    }]

    "---"

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
        tool: 'circle'
        name: 'Circle'
        icon: (ctx, box) ->
            p = 0.24
            a = {x: 0.5, y: 0.5}
            b = {x: 1-p, y: p}

            Draw.point(ctx, box, a)
            Draw.point(ctx, box, b)

            Draw.circle(ctx, box, {x: a.x, y: a.y, r: distance(a, b)})
    },{
        tool: 'triangle'
        name: 'Driehoek'
        icon: (ctx, box) ->
            p = 0.18

            a = {x: 0.5, y: (1-p*1.3) - (1-p*2)*sqrt(3)/2}
            b = {x: p, y: 1-p*1.3}
            c = {x: 1-p, y: 1-p*1.3}

            Draw.point ctx, box, a
            Draw.point ctx, box, b
            Draw.point ctx, box, c

            Draw.line  ctx, box, {p1: a, p2: b}
            Draw.line  ctx, box, {p1: b, p2: c}
            Draw.line  ctx, box, {p1: c, p2: a}
    },{
        tool: 'square'
        name: 'Vierkant'
        icon: (ctx, box) ->
            p = 0.18
            a = {x: p,   y: p}
            b = {x: 1-p, y: p}
            c = {x: 1-p, y: 1-p}
            d = {x: p,   y: 1-p}

            Draw.point ctx, box, a
            Draw.point ctx, box, b
            Draw.point ctx, box, c
            Draw.point ctx, box, d

            Draw.line  ctx, box, {p1: a, p2: b}
            Draw.line  ctx, box, {p1: b, p2: c}
            Draw.line  ctx, box, {p1: c, p2: d}
            Draw.line  ctx, box, {p1: d, p2: a}
    }]

    [{
        tool: 'bisectrice'
        name: 'Bisectrice'
        icon: (ctx, box) ->
            p = 0.18

            a = {x: p,   y: 0.5}
            b = {x: 1-p, y: p}
            c = {x: 1-p, y: 1-p}
            d = {x: 1, y: 0.5}

            Draw.point(ctx, box, a)
            Draw.point(ctx, box, b)
            Draw.point(ctx, box, c)

            Draw.line(ctx, box, {p1: a, p2: b})
            Draw.line(ctx, box, {p1: a, p2: c})
            Draw.line(ctx, box, {p1: a, p2: d})
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
        tool: 'awesome_circles'
        name: 'Cirkels demo'
    },{
        tool: 'awesome_lines'
        name: 'Lijnen demo'
    }]
]

Settings.toolbar.size = 42

globalize {Settings}