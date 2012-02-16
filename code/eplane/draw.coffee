
magic_circle = (ctx, x, y, r) ->
  m = 0.551784

  ctx.save()
  ctx.translate(x, y)
  ctx.scale(r, r)
  ctx.moveTo(1, 0)
  ctx.bezierCurveTo(1,  -m,  m, -1,  0, -1)
  ctx.bezierCurveTo(-m, -1, -1, -m, -1,  0)
  ctx.bezierCurveTo(-1,  m, -m,  1,  0,  1)
  ctx.bezierCurveTo( m,  1,  1,  m,  1,  0)
  ctx.closePath()
  ctx.restore()

Settings =
    point:
        draw_radius: 2.5
        hit_radius:  10
        label_distance: 17
        create_distance: 6 # de afstand waarna de engine overgaat in selecte ipv puntmaken
        
    select:
        segment_length: 5
        segment_jmp: 33
        
    label:
        dx: 10
        dy: 0
        d: 7.5
        font_size: 11
        
    listing:
        x: 5
        y: 5
        font_size: 12
        line_height: 1.33
        
    scale: 10
    
    color:
        light1: "#e0e0e0"
        light2: "#c0c0c0"
    
Show =
    coords: ({x, y}) -> "(#{(x/Settings.scale).toFixed(1)},#{(y/Settings.scale).toFixed(1)})"

Draw =
  point: (ctx, space, p) ->
    ctx.beginPath()
    ctx.fillStyle = "#006cff"
    ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.draw_radius, 0, TAU, true)
    ctx.closePath()
    ctx.fill()
    
  points: (ctx, space, ps) ->
    culledPs = []
    gridMap = {}
    ps = ps.filter (p) ->
      x  = round p.x
      y  = round p.y

      if gridMap[x]? and gridMap[x][y]? and gridMap[x][y].some ((other) -> distance(p, other) < sml)
        return false 
      else
        gridMap[x]  ?= {}
        gridMap[x][y] ?= []
        gridMap[x][y].push p
        return true

    #dependent points
    ctx.fillStyle = ctx.strokeStyle = "#666"
    dp = ps.filter (p) -> not p.free

    #draw points
    ctx.beginPath()
    dp.filter((p) -> not space.shouldCullPoint p).forEach (p) ->
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.draw_radius, 0, TAU, true)
      ctx.closePath()
    ctx.fill()

    #draw hover radi
    ctx.beginPath()
    ctx.lineWidth = 1
    dp.filter((p) -> p.hover).forEach (p) ->
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.hit_radius, 0, TAU, true)
      ctx.closePath()
    ctx.stroke()

    #free points
    ctx.fillStyle = ctx.strokeStyle = "#006cff"
    fp = ps.filter (p) -> p.free

    #draw points
    ctx.beginPath()
    fp.forEach (p) ->
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.draw_radius, 0, TAU, true)
      ctx.closePath()
    ctx.fill()
    
    #draw hover radi
    ctx.beginPath()
    ctx.lineWidth = 1
    fp.filter((p) -> p.hover).forEach (p) ->
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.hit_radius, 0, TAU, true)
      ctx.closePath()
    ctx.stroke()
    
    # draw labels
    if EuclidesApp.labels
      ctx.fillStyle = "#000"
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      ps.filter((point) -> point.name?).forEach (p) ->
        if p.name
          ctx.fillText p.name, p.x * space.box.scale + Settings.point.label_distance, p.y * space.box.scale
  
  rawLine: (ctx, l, box) ->
      if not l.extended
        ctx.moveTo(l.p1.x * box.scale, l.p1.y * box.scale)
        ctx.lineTo(l.p2.x * box.scale, l.p2.y * box.scale)
      else 
        if l.vertical
          ctx.moveTo(l.x1 * box.scale, box.top)
          ctx.lineTo(l.x2 * box.scale, box.bottom)
        else
          ctx.moveTo(box.left, l.rc * box.left + l.hc * box.scale)
          ctx.lineTo(box.right, l.rc * box.right + l.hc * box.scale)
  
  line: (ctx, space, l) ->
    ctx.strokeStyle = "#666"
    ctx.beginPath()
    Draw.rawLine ctx, l, space.box
    ctx.stroke()
  
  lines: (ctx, space, ls) ->
    ctx.lineWidth = 1  
    
    #draw normal lines
    ctx.strokeStyle = "#666"
    ctx.beginPath()
    ls.filter((o) -> not o.selected).forEach  (l) -> Draw.rawLine ctx, l, space.box
    ctx.stroke()
    
    #draw selected lines
    ctx.strokeStyle = "blue"
    ctx.beginPath()
    ls.filter((o) -> o.selected).forEach      (l) -> Draw.rawLine ctx, l, space.box
    ctx.stroke()
    
    # draw labels
    if EuclidesApp.labels
      ctx.fillStyle = "#000"
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      ls.filter((o) -> o.name?).forEach (l) ->
        lx = l.x1 + (l.x2 - l.x1)*0.382
        ly = l.y1 + (l.y2 - l.y1)*0.382
        c = Settings.label.d/(l.length * space.box.scale)
        ctx.fillText l.name, (lx - c*(l.y1-l.y2)) * space.box.scale, (ly + c*(l.x1-l.x2)) * space.box.scale
  
  circle: (ctx, space, c) ->
    ctx.beginPath()
    ctx.strokeStyle = "#666"
    ctx.lineWidth = 1
    magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
         
  circles: (ctx, space, cs) ->
    #draw normal circles
    ctx.strokeStyle = "#666"
    ctx.lineWidth = 1
    ctx.beginPath()
    cs.filter((o) -> not o.selected).forEach (c) -> magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
    
    #draw selected circles
    ctx.strokeStyle = "blue"
    ctx.lineWidth = 1
    ctx.beginPath()

    cs.filter((o) -> o.selected).forEach     (c) -> magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
    
    if EuclidesApp.labels
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      cs.filter((o) -> o.name?).forEach (c) ->
        dx = (c.x - c.p2.x)
        dy = (c.y - c.p2.y)
        d = sqrt(sq(dx)+sq(dy)) * space.box.scale + Settings.label.d
        a = c.angle-2.4
        
        lx = c.x * space.box.scale + d*cos(a)
        ly = c.y * space.box.scale + d*sin(a)
                
        ctx.fillText c.name, lx, ly
        
  selectionLine: (ctx, space, ps, mouse) ->
        ctx.strokeStyle = "#66F"
        ctx.lineWidth = 1
    
        ctx.beginPath()
        ctx.moveTo(ps[0].x * space.box.scale, ps[0].y * space.box.scale)
    
        if ps.length < 2
        else
            for i in [1...(ps.length-1)]
                xc = (ps[i].x + ps[i+1].x) / 2
                yc = (ps[i].y + ps[i+1].y) / 2
                
                ctx.quadraticCurveTo(ps[i].x * space.box.scale, ps[i].y * space.box.scale, xc * space.box.scale, yc * space.box.scale);
        
        i = ps.length-1
        
        ctx.quadraticCurveTo(ps[i].x * space.box.scale, ps[i].y * space.box.scale, mouse.x * space.box.scale, mouse.y * space.box.scale);

        ctx.stroke()
        
  bgGrid: (ctx, space) ->
        ctx.strokeStyle = Settings.color.light1
        ctx.lineWidth = 1
        
        ctx.beginPath()
        #ctx.translate(-0.5, -0.5)
        
        i = 1
        while (d = Settings.scale * space.box.scale * i++) < space.box.right
            ctx.moveTo d, space.box.top
            ctx.lineTo d, space.box.bottom

        i = -1
        while (d = Settings.scale * space.box.scale * i--) > space.box.left
            ctx.moveTo d, space.box.top
            ctx.lineTo d, space.box.bottom
        
        i = 1
        while (d = Settings.scale * space.box.scale * i++) < space.box.bottom
            ctx.moveTo space.box.left,  d
            ctx.lineTo space.box.right, d

        i = -1
        while (d = Settings.scale * space.box.scale * i--) > space.box.top
            ctx.moveTo space.box.left,  d
            ctx.lineTo space.box.right, d
            
        ctx.stroke()
        
        ctx.lineWidth = 1
        ctx.strokeStyle = Settings.color.light2
        
        ctx.beginPath()
        
        ctx.moveTo(0, space.box.top)
        ctx.lineTo(0, space.box.bottom)
        
        ctx.moveTo(space.box.left, 0)
        ctx.lineTo(space.box.right, 0)
        
        ctx.stroke()
        
        #ctx.translate(0.5, 0.5)
                
globalize {Draw, Settings, Show}
