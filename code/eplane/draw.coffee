`function roundRect(ctx, x, y, width, height, radius) {
  if (typeof radius === "undefined") {
    radius = 5;
  }
  ctx.beginPath();
  ctx.moveTo(x + radius, y);
  ctx.lineTo(x + width - radius, y);
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
  ctx.lineTo(x + width, y + height - radius);
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
  ctx.lineTo(x + radius, y + height);
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
  ctx.lineTo(x, y + radius);
  ctx.quadraticCurveTo(x, y, x + radius, y);
  ctx.closePath();
}`


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
    coords: ({x, y}) -> "(#{(x/Settings.grid.scale).toFixed(1)},#{(y/Settings.grid.scale).toFixed(1)})"

Draw =
  magic: (ctx, space, thing) -> switch thing.type
    when 'Point'  then Draw.point  ctx, space, thing
    when 'Line'   then Draw.line   ctx, space, thing
    when 'Circle' then Draw.circle ctx, space, thing

  point: (ctx, space, p) ->
    space = {box: space} if space.scale?

    ctx.fillStyle = if p.free? and not p.free then Settings.point.color else Settings.point.free.color

    ctx.beginPath()
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


    drawPointGroup = (group) ->
      #group = group.filter (p) -> not space.shouldCullPoint p

      #points
      ctx.beginPath()
      group.forEach (p) ->
        x = p.x * space.box.scale
        y = p.y * space.box.scale
        r = Settings.point.draw_radius

        ctx.moveTo x+r, y
        ctx.arc x, y, r, 0, TAU
      ctx.fill()

      #hover radi
      ctx.beginPath()
      group.filter((p) -> p.hover or p.selected).forEach (p) ->
        x = p.x * space.box.scale
        y = p.y * space.box.scale
        r = Settings.point.hover_draw_radius

        ctx.moveTo x+r, y
        ctx.arc x, y, r, 0, TAU
      ctx.stroke()

    ctx.lineWidth = 1

    #dependent points
    ctx.fillStyle = ctx.strokeStyle = Settings.point.color
    drawPointGroup ps.filter((p) -> not p.free)

    #free points
    ctx.fillStyle = ctx.strokeStyle = Settings.point.free.color
    drawPointGroup ps.filter((p) -> p.free)
    
    # draw labels
    if space.labels
      ctx.fillStyle = Settings.label.color
      ctx.font = "#{Settings.label.font_size}px #{Settings.label.font_family}"
      ctx.textBaseline = "alphabetic"
      ctx.textAlign = "left"
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

    ctx.lineWidth = if l?.helper then Settings.shape.helper.line_width else 1
    ctx.strokeStyle = if l?.selected then Settings.shape.selected.color else Settings.shape.color
    ctx.beginPath()
    Draw.rawLine ctx, l, space.box
    ctx.stroke()
  
  lines: (ctx, space, ls) ->
    # draw helper lines
    ctx.strokeStyle = Settings.shape.helper.color
    ctx.lineWidth = Settings.shape.helper.line_width
    ctx.beginPath()
    ls.filter((o) -> o.helper).forEach (l) -> Draw.rawLine ctx, l, space.box
    ctx.stroke()

    # draw normal lines
    ctx.lineWidth = Settings.shape.line_width
    ctx.strokeStyle = Settings.shape.color
    ctx.beginPath()
    ls.filter((o) -> not o.helper and not o.selected).forEach  (l) -> Draw.rawLine ctx, l, space.box
    ctx.stroke()
    
    # draw selected lines
    ctx.strokeStyle = Settings.shape.selected.color
    ctx.lineWidth = Settings.shape.selected.line_width
    ctx.beginPath()
    ls.filter((o) -> not o.helper and o.selected).forEach      (l) -> Draw.rawLine ctx, l, space.box
    ctx.stroke()
    
    # draw labels
    if space.labels
      ctx.fillStyle = Settings.label.color
      ctx.font = "#{Settings.label.font_size}px #{Settings.label.font_family}"
      ctx.textBaseline = "middle"
      ctx.textAlign = "center"
      ls.filter((o) -> o.name).forEach (l) ->
        lx = l.x1 + (l.x2 - l.x1)*0.382
        ly = l.y1 + (l.y2 - l.y1)*0.382
        c = Settings.label.d/(l.length * space.box.scale)
        ctx.fillText l.name, (lx - c*(l.y1-l.y2)) * space.box.scale, (ly + c*(l.x1-l.x2)) * space.box.scale
  
  circle: (ctx, space, c) ->
    space = {box: space} if space.scale?

    ctx.beginPath()
    ctx.lineWidth = if c?.helper then Settings.shape.helper.line_width else 1
    ctx.strokeStyle = if c?.selected then Settings.shape.selected.color else Settings.shape.color
    magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
         
  circles: (ctx, space, cs) ->
    # draw helper circles
    ctx.strokeStyle = Settings.shape.helper.color
    ctx.lineWidth = Settings.shape.helper.line_width
    ctx.beginPath()
    cs.filter((o) -> o.helper).forEach (c) -> magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()

    #draw normal circles
    ctx.strokeStyle = Settings.shape.color
    ctx.lineWidth = Settings.shape.line_width
    ctx.beginPath()
    cs.filter((o) -> not o.helper and not o.selected).forEach (c) -> magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
    
    #draw selected circles
    ctx.strokeStyle = Settings.shape.selected.color
    ctx.lineWidth = Settings.shape.selected.line_width
    ctx.beginPath()

    cs.filter((o) -> not o.helper and o.selected).forEach     (c) -> magic_circle(ctx, c.x * space.box.scale, c.y * space.box.scale, c.r * space.box.scale)
    ctx.stroke()
    
    if space.labels
      ctx.fillStyle = Settings.label.color
      ctx.font = "#{Settings.label.font_size}px #{Settings.label.font_family}"
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
  
  selectionBox: (ctx, space, origin, target) ->
      ctx.strokeStyle = "#66F"
      ctx.lineWidth = 1

      ctx.beginPath()
      ctx.moveTo origin.x * space.box.scale, origin.y * space.box.scale
      ctx.lineTo target.x * space.box.scale, origin.y * space.box.scale
      ctx.lineTo target.x * space.box.scale, target.y * space.box.scale
      ctx.lineTo origin.x * space.box.scale, target.y * space.box.scale
      ctx.closePath()

      ctx.stroke()

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
    
    q = log(space.box.scale)/log(Settings.grid.scale)
    q += 0.25
    res1 = floor q 
    res2 = res1 - 1

    ctx.beginPath()
    @bgGridRaw ctx, space, (Settings.grid.scale * space.box.scale * pow(Settings.grid.scale, -res1))
    ctx.strokeStyle = c Settings.grid.lightness * min(1, abs(res1 - q))
    ctx.stroke()

    ctx.beginPath()
    @bgGridRaw ctx, space, (Settings.grid.scale * space.box.scale * pow(Settings.grid.scale, -res2))
    ctx.strokeStyle = c Settings.grid.lightness * min(1, abs(res2 - q))
    ctx.stroke()
    
    ctx.translate(-0.5, -0.5)
    ctx.lineWidth = 1.5
    ctx.strokeStyle = Settings.grid.axis
    
    ctx.beginPath()
    
    ctx.moveTo(0, space.box.top)
    ctx.lineTo(0, space.box.bottom)
    
    ctx.moveTo(space.box.left, 0)
    ctx.lineTo(space.box.right, 0)
    
    ctx.stroke()
    
    ctx.translate(0.5, 0.5)
                
globalize {Draw, Show}
