sml = 0.1

Intersection = (a, b, n=0) ->
    mode = Intersection.mode(a, b)        
    count = Intersection.count(mode)
            
    if not (0 <= n < count)
        throw new Error("That (##{n}) is not a valid intersection number")
        
    return Intersection.raw(mode, a, b, n)

Intersection.any = (a, b) ->
    mode = Intersection.mode(a, b)        
    count = Intersection.count(mode)
        
    for i in [0...count]
        intersect = Intersection.raw(mode, a, b, i)
        return true if not intersect.virtual
        
    return false

Intersection.mode = (a, b) ->
    switch
        when a instanceof Line    &&  b instanceof Line    then  "LineLine"
        when a instanceof Line    &&  b instanceof Circle  then  "LineCircle"
        when a instanceof Circle  &&  b instanceof Line    then  "CircleLine"
        when a instanceof Circle  &&  b instanceof Circle  then  "CircleCircle"
        else 
            console.log a
            console.log b
            throw new Error("Can't intersect between that!")
    
Intersection.count = (mode) ->
    switch mode
        when "LineLine" then 1
        else 2
        
Intersection.method = (a, b) ->
    mode = Intersection.mode(a, b)

    swap = false
    if mode == "CircleLine"
        mode = "LineCircle"
        tmp = a
        a = b
        b = tmp
        swap = true
        
    for method in Intersection[mode]
        result = method(a, b, 0, true)
        break if result
    
    return if swap then ((b, a, n) -> method(a, b, n)) else method
    
Intersection.raw = (mode, a, b, n) ->
    if mode == "CircleLine"
        mode = "LineCircle"
        tmp = a
        a = b
        b = tmp

    for method in Intersection[mode]
        result = method(a, b, n, true)
        break if result
    
    return result
    
Intersection.LineLine = # containing line line intersection rules
[   (a, b) -> # base case, always match
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

Intersection.LineCircle = # containing line circle intersection rules
[   (l, c, n) ->
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
        
        if c.p2.laysOn l
            return {virtual: true} if n == 0
            
            mu = 1
            
            while true
                x = (D * dy + mu * dx * sqrt(disc)) / sq(dr)
                y = (-D * dx + mu * sgn(dy) * abs(dy) * sqrt(disc)) / sq(dr)
                
                if distance(c.p2, {x: c.x+x, y: c.y+y}) > sml
                    virtual = not (l.extended or ((x1 <= x <= x2) or (x2 <= x <= x1)) and ((y1 <= y <= y2) or (y2 <= y <= y1)))
                    
                    return {x: c.x + x, y: c.y + y, virtual}
                else if mu == 1
                    mu = -1
                else
                    return {virtual: true}

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

sqrt3over2 = Math.sqrt(3)/2

Intersection.CircleCircle = # containing circle cirle intersection rules
[   (a, b, n, scan=false) -> # equal 60-60-60 triangle
        if scan
            return false if not (a.p1 == b.p2 and a.p2 == b.p1)
        
        dx = b.x - a.x
        dy = b.y - a.y 
        
        mu = switch n
            when 0 then -1
            when 1 then 1
            else throw new Error("Invalid #n CircleCircle intersection")
        
        x = a.x + dx/2 + mu * sqrt3over2 * dy
        y = a.y + dy/2 - mu * sqrt3over2 * dx
        
        return {x, y, virtual: false}
            
,  (a, b, n) ->
        
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
        
        c1 = a.p2.laysOn b
        c2 = b.p2.laysOn a
        if c1 or c2
            if n == 1 then return {virtual: true}
            
            rp = if c1 then a.p2 else b.p2
            
            mu = -1
            while true
                x = x2 + mu * rx
                y = y2 + mu * ry
                
                break if distance(rp, {x, y}) > sml

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

globalize {Intersection}
