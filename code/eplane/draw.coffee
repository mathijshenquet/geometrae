
magic_circle = (ctx, x, y, r) ->
  ctx.save()
  ctx.translate(x, y)
  ctx.scale(r, r)

  m = 0.2652031
  r = TAU / 8
  isq = 1/sqrt(2)

  f = -> ctx.bezierCurveTo m, 1, (1-m)*isq, (1+m)*isq, isq, isq

  ctx.moveTo(0, 1)
  for i in [0...8]
    ctx.lineTo(-.0001, 1)
    ctx.lineTo(+.0001, 1)
    f()
    ctx.rotate(-r)

  #ctx.closePath()
  ctx.restore()
    
Show =
    coords: ({x, y}) -> "(#{(x/Settings.scale).toFixed(1)},#{(y/Settings.scale).toFixed(1)})"

Draw =
  magic: (ctx, space, thing) -> switch
    when thing instanceof Point  then Draw.point  ctx, space, thing
    when thing instanceof Line   then Draw.line   ctx, space, thing
    when thing instanceof Circle then Draw.circle ctx, space, thing

  point: (ctx, space, p) ->
    space = {box: space} if space.scale?

    ctx.beginPath()
    ctx.fillStyle = "#006cff"
    ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.draw_radius, 0, TAU, true)
    ctx.closePath()
    ctx.fill()
    
  points: (ctx, space, ps) ->
    culledPs = []
    gridMap = {}
    ps = ps.filter (p) ->
      x  = round (p.x * space.box.scale)
      y  = round (p.y * space.box.scale)

      if gridMap[x]? and gridMap[x][y]?
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
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.hover_draw_radius, 0, TAU, true)
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
      ctx.arc(p.x * space.box.scale, p.y * space.box.scale, Settings.point.hover_draw_radius, 0, TAU, true)
      ctx.closePath()
    ctx.stroke()
    
    # draw labels
    if space.labels
      ctx.fillStyle = "#000"
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      ps.filter((point) -> point.name).forEach (p) ->
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
    space = {box: space} if space.scale?

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
    if space.labels
      ctx.fillStyle = "#000"
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      ls.filter((o) -> o.name).forEach (l) ->
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
    
    if space.labels
      ctx.font = "#{Settings.label.font_size}px sans-serif"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      cs.filter((o) -> o.name).forEach (c) ->
        dx = (c.x - c.p2.x)
        dy = (c.y - c.p2.y)
        d = sqrt(sq(dx)+sq(dy)) * space.box.scale + Settings.label.d
        a = c.angle-2.4
        
        lx = c.x * space.box.scale + d*cos(a)
        ly = c.y * space.box.scale + d*sin(a)
                
        ctx.fillText c.name, lx, ly
        
  selectionLine: (ctx, space, ps, mouse) ->
        return null if ps.length < 2

        ctx.strokeStyle = "#66F"
        ctx.lineWidth = 1

        ctx.beginPath()
        ctx.moveTo(ps[0].x * space.box.scale, ps[0].y * space.box.scale)
    
        for i in [1...(ps.length-1)]
            xc = (ps[i].x + ps[i+1].x) / 2
            yc = (ps[i].y + ps[i+1].y) / 2
            
            ctx.quadraticCurveTo(ps[i].x * space.box.scale, ps[i].y * space.box.scale, xc * space.box.scale, yc * space.box.scale);
    
        i = ps.length-1
    
        ctx.quadraticCurveTo(ps[i].x * space.box.scale, ps[i].y * space.box.scale, mouse.x * space.box.scale, mouse.y * space.box.scale);

        ctx.stroke()
  
  bgGridRaw: (ctx, space, res) ->
    i = 1
    while (d = res * i++) < space.box.right
      dp = round(d)
      ctx.moveTo dp, space.box.top
      ctx.lineTo dp, space.box.bottom

    i = -1
    while (d = res * i--) > space.box.left
      dp = round(d)
      ctx.moveTo dp, space.box.top
      ctx.lineTo dp, space.box.bottom
    
    i = 1
    while (d = res * i++) < space.box.bottom
      dp = round(d)
      ctx.moveTo space.box.left,  dp
      ctx.lineTo space.box.right, dp

    i = -1
    while (d = res * i--) > space.box.top
      dp = round(d)
      ctx.moveTo space.box.left,  dp
      ctx.lineTo space.box.right, dp

  bgGrid: (ctx, space) ->
    c = (l) -> "rgba(0, 0, 0, #{l})"
    ctx.lineWidth = 1
    
    #ctx.translate(-0.5, -0.5)
    
    q = log(space.box.scale)/log(Settings.scale)
    q += 0.25
    res1 = floor q 
    res2 = res1 - 1

    ctx.beginPath()
    @bgGridRaw ctx, space, (Settings.scale * space.box.scale * pow(Settings.scale, -res1))
    ctx.strokeStyle = c Settings.grid.lightness * min(1, abs(res1 - q))
    ctx.stroke()

    ctx.beginPath()
    @bgGridRaw ctx, space, (Settings.scale * space.box.scale * pow(Settings.scale, -res2))
    ctx.strokeStyle = c Settings.grid.lightness * min(1, abs(res2 - q))
    ctx.stroke()
    
    ctx.translate(-0.5, -0.5)
    ctx.lineWidth = 1.5
    ctx.strokeStyle = Settings.color.light2
    
    ctx.beginPath()
    
    ctx.moveTo(0, space.box.top)
    ctx.lineTo(0, space.box.bottom)
    
    ctx.moveTo(space.box.left, 0)
    ctx.lineTo(space.box.right, 0)
    
    ctx.stroke()
    
    ctx.translate(0.5, 0.5)
                
globalize {Draw, Show}
