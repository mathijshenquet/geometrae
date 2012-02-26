#dsl

punt = point = (a, b, n=1) ->
	_ = new DependentPoint(a, b, n)
	_.helper = true
	_.hidden = true
	_

lijn = line = (a, b) ->
	_ = new Line(a, b)
	_.helper = true
	_.extended = true
	_.hidden = true
	_

seg = (a, b) ->
	_ = new Line(a, b)
	_.helper = true
	_.hidden = true
	_

cirkel = circle = (a, b) ->
	_ = new Circle(a, b)
	_.helper = true
	_.hidden = true
	_

teken = paint = (objects...) ->
	for object in objects
		object.hidden = false

	objects

toon = show = (objects...) ->
	for object in objects
		object.helper = false
		object.hidden = false

	objects

Constructions =
	line: (a, b) ->
		l = lijn a, b
		show l
		l.extended = false
		[a, b, l]

	line_extended: (a, b) ->
		l = lijn a, b
		show l
		[a, b, l]

	bisectrice: (a, c, b_) ->
		l1 	= line c, a
		l2 	= line c, b_

		eq 	= circle c, a
		b 	= point eq, l2

		c1 	= circle a, b
		c2 	= circle b, a

		i_ 	= point c1, c2
		bis_= line c, i_

		mid = line a, b_
		i 	= point bis_, mid

		bis = line c, i

		show(i, bis, l1, l2)

		[a, c, b_, l1, l2, eq, b, c1, c2, i_, bis_, mid, i, bis]

	loodlijn: (a, b, t1) ->
		c1 = circle a, t1
		c2 = circle b, t1

		t2 = point c1, c2, 0

		l = line t1, t2

		show t1, t2, l

		[a, b, c1, c2, t1, t2, l]

	middelloodlijn: (a, b) ->
		c1 = circle a, b
		c2 = circle b, a

		i1 = point c1, c2
		i2 = point c2, c1

		l = lijn i1, i2

		show i1, i2, l

		[a, b, c1, c2, i1, i2, l]

	triangle: (a, b) ->
		c1 = circle a, b
		c2 = circle b, a

		c = point c1, c2

		l1 = lijn a, b
		l2 = lijn b, c
		l3 = lijn c, a

		l1.extended = l2.extended = l3.extended = false

		show l1, l2, l3, c

		[a, b, c, c1, c2, l1, l2, l3]

	square: (a, b) ->
		h1 = lijn a, b
		c1 = circle a, b
		p1 = punt c1, h1

		c2 = circle p1, b
		c3 = circle b, p1
		p2 = punt c2, c3
		h2 = lijn a, p2

		c = punt c1, h2

		c4 = circle c, a
		c5 = circle b, a

		d = punt c5, c4, 0

		l1 = lijn a, b
		l2 = lijn b, d
		l3 = lijn d, c
		l4 = lijn c, a

		l1.extended = l2.extended = l3.extended = l4.extended = false

		show c, d, l1, l2, l3, l4

		[a, b, c, d, h1, h2, c1, c2, c3, c4, c5, p1, p2, l1, l2, l3, l4]

	awesome_circles: (a, c, b) ->
		orbit = circle a, b
		l = lijn a, c
		i = punt orbit, l

		objects = [a, b, c, i, orbit, l]
		p1 = b
		p2 = i
		for [0..64]
			ci = circle p2, p1
			p1 = p2
			p2 = punt orbit, ci, 0

			paint ci

			objects.push ci
			objects.push p2

		objects

	awesome_lines: (a, c, b) ->
		orbit = circle a, b
		l = lijn a, c
		i = punt orbit, l

		objects = [a, b, c, i, orbit, l]
		[p1, p2] = [b, i]
		paint p1, p2

		points = [p1, p2]
		for [0...32]
			ci = circle p2, p1
			p1 = p2
			p2 = punt orbit, ci, 0

			paint p2

			points.push p2

			objects.push ci
			objects.push p2

		for i in [0...points.length]
			for j in [i...points.length]
				a = points[i]
				b = points[j]
				l = seg a, b
				paint l
				objects.push l

		objects


globalize {Constructions}