Intersection = {}

Intersection.info = (a, b, opts={}) ->
    algorithm = if opts.precise then "precise" else "approximation"

    mode = "#{a.type}#{b.type}"

    throw new Error("Can't intersect between that! (#{a}:#{a.type} #{b}:#{b.type})") unless (a.type == "Line" or a.type == "Circle") and (b.type == "Line" or b.type == "Circle")
    
    count = switch mode
        when "LineLine" then 1
        else 2

    return {mode, count, algorithm}

Intersection.method = (a, b, opts) ->
    {mode, count, algorithm} = Intersection.info(a, b, opts)

    if mode == "CircleLine"
        mode = "LineCircle"
        [a, b] = [b, a]

    for method in Intersection[algorithm][mode]
        if (result = method(a, b)) then return result

    return false

Intersection.has = (a, b, opts) ->
    {mode, count, algorithm} = Intersection.info(a, b, opts)
        
    method = Intersection.method(a, b, opts)
    for i in [0...count]
        return true if not (intersection = method(i)).virtual
        
    return false

sqrt3over2 = Math.sqrt(3)/2

Intersection.approximation =
    LineLine: [
        (a, b) -> (n) -> # base case, always match
            switch
                when a.vertical
                    y = b.rc * a.x1 + b.hc
                    x = a.x1
                when b.vertical
                    y = a.rc * b.x1 + a.hc
                    x = b.x1
                else
                    x = (b.hc - a.hc)/(a.rc - b.rc)
                    y = a.hc + a.rc * x
            
            lays_on = (o) ->
                xl = min(o.x1, o.x2)
                xh = max(o.x1, o.x2)
                
                yl = min(o.y1, o.y2)
                yh = max(o.y1, o.y2)
                
                (xl <= x <= xh) && (yl <= y <= yh)
                
            virtual = not ((a.extended or lays_on(a)) and (b.extended or lays_on(b)))
            {x, y, virtual}
    ]

    LineCircle: [
        (l, c) -> (n) ->
            x1 = l.x1 - c.x
            y1 = l.y1 - c.y
            x2 = l.x2 - c.x
            y2 = l.y2 - c.y
            r = c.r

            dx = x2 - x1
            dy = y2 - y1
            dr = sqrt(sq(dx)+sq(dy))
            D = x1*y2 - x2*y1
            
            disc = sq(r)*sq(dr)-sq(D)

            if disc < 0
                return {virtual: true}

            if c.p2 == l.p1 or c.p2 == l.p2
                return {virtual: true} if n == 0
                
                f = (mu) ->
                    x = c.x + (D * dy + mu * dx * sqrt(disc)) / sq(dr)
                    y = c.y + (-D * dx + mu * sgn(dy) * abs(dy) * sqrt(disc)) / sq(dr)
                    {x, y}

                d1 = distance(c.p2, f(-1))
                d2 = distance(c.p2, f(1))

                mu = if d1 > d2 then -1 else 1
            else
                mu = switch n
                    when 0 then -1
                    when 1 then 1
                    else throw new Error("Invalid #n LineCircle intersection")
                
            x = (D * dy + mu * dx * sqrt(disc)) / sq(dr)
            y = (-D * dx + mu * sgn(dy) * abs(dy) * sqrt(disc)) / sq(dr)
            virtual = not (l.extended or ((x1 <= x <= x2) or (x2 <= x <= x1)) and ((y1 <= y <= y2) or (y2 <= y <= y1)))
            
            return {x: c.x + x, y: c.y + y, virtual}
    ]

    CircleCircle: [ # containing circle cirle intersection rules
       (a, b) -> # equal 60-60-60 triangle
            return false unless (a.p1 == b.p2 and a.p2 == b.p1)
            
            (n) ->           
                dx = b.x - a.x
                dy = b.y - a.y 
                
                mu = switch n
                    when 0 then -1
                    when 1 then 1
                    else throw new Error("Invalid #n CircleCircle intersection")
                
                x = a.x + dx/2 + mu * sqrt3over2 * dy
                y = a.y + dy/2 - mu * sqrt3over2 * dx
                
                return {x, y, virtual: false}
            
        (a, b) -> (n) ->
        
            x0 = a.x
            y0 = a.y
            r0 = a.r
            x1 = b.x
            y1 = b.y
            r1 = b.r
            
            dx = x1 - x0
            dy = y1 - y0
            
            d = distance(a, b)
            
            return {virtual: true} if d > (r0 + r1) or d < abs(r0 - r1) or (d == 0 and r0 == r1)
            
            p = ((r0*r0) - (r1*r1) + (d*d)) / (2*d)

            x2 = x0 + (dx * p/d)
            y2 = y0 + (dy * p/d)

            h = sqrt((r0*r0) - (p*p))

            rx = -dy * (h/d);
            ry = dx * (h/d);
            
            if a.p2 == b.p2
                if n == 1 then return {virtual: true}
                
                rp = a.p2
                
                mu = -1
                while true
                    x = x2 + mu * rx
                    y = y2 + mu * ry
                    
                    break if not (feq(rp.x, x, max(r0, r1)) and feq(rp.y, y, max(r0, r1)))
                    break if mu == 1

                    mu = 1
                        
                return {x, y, virtual: false}
            
            else 
                mu = switch n
                    when 0 then -1
                    when 1 then 1
                    else throw new Error("Invalid #n CircleCircle intersection")

                x = x2 + mu * rx
                y = y2 + mu * ry
                
                return {x, y, virtual: false}
    ]

Intersection.precise =
    LineLine: [
        (a, b) -> (n) -> # base case, always match
            pool = Intersection.pool

            scope =
                x1: a.p1.px
                y1: a.p1.py

                x2: a.p2.px
                y2: a.p2.py

                x3: b.p1.px
                y3: b.p1.py

                x4: b.p2.px
                y4: b.p2.py

            {x, y} = pool.execute scope, """
                rca = (y2 - y1) / (x2 - x1)
                hca = y1 / (rca * x1)

                rcb = (y4 - y3) / (x4 - x3)
                hcb = y3 / (rcb * x3)

                x = (hcb - hca)/(rca - rcb) 
                y = hca + rca * x
            """

            {x, y}
    ]

    LineCircle: [
        (l, c) -> (n) ->
    ]

    CircleCircle: [ # containing circle cirle intersection rules
        (a, b) -> (n) ->
    ]

globalize {Intersection}
