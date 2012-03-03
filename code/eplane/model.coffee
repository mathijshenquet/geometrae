# The Entity class is the parent class for all the algebraic structures that live on the euclidean plane.
# It mainly contains entity hierachy (which entity depends on which). And general behaviour (hidability, recycling)
class Entity
    id_pool = 0
  
    @attr "visible" # Visibility is wether the element is to be drawn
        get: -> not @virtual and not @hidden and not @destroyed

    @attr "needsUpdate"
        get: -> not @valid

    @attr "destroyed"
        get: -> @destroy_count > 0

    @unique: `function(arr) {
        var hash = {}, result = [];
        for ( var i = 0, l = arr.length; i < l; ++i ) {
            if ( !hash.hasOwnProperty(arr[i].id) ) {
                hash[ arr[i].id ] = true;
                result.push(arr[i]);
            }
        }
        return result;
    }`    
    
    # We initialize objects to set properies that are to be used by the instances of entity.
    initialize: (parents=[], @space) ->
        # Hierachy        
        @children = []
        @parents = []
        for parent in parents
            @parents.push parent

        @space ?= parents[0].space
          
        @dependingObjects = []
        @ancestors        = @calculateAncestors()
        @roots            = @calculateRoots()

        # Logical state
        @valid         = false
        @destroy_count = 1
        @virtual       = false
        @helper        = false
        
        # Misc state, used by the drawing engine
        @hidden     = false
        @selected   = false
        @hover      = false
        
        @name = null
        
        @id = id_pool++

        @undestroy()
    
    undestroy: ->
        dep.destroy_count-- for dep in @dependingObjects if @dependingObjects?
        @destroy_count--

        if not @destroyed
            for parent in @parents
                parent.addChild this

            for ancestor in @ancestors
                ancestor.addDep this

    destroy: ->
        for parent in @parents
            parent.removeChild this

        for ancestor in @ancestors
            ancestor.removeDep this 

        dep.destroy_count++ for dep in @dependingObjects if @dependingObjects?
        @destroy_count++
    
    addChild: (c) ->
        if @destroyed
          c.destroy()
          return false
      
        @children.push c
    
    removeChild: (t) -> @children = @children.filter (c) -> c.id != t.id
    
    addDep: (dep)    -> @dependingObjects.push dep

    removeDep: (dep) -> @dependingObjects = @dependingObjects.filter (o) -> o.id != dep.id

    # Invalidate the entity, forcing recalculation when necessary
    invalidate: ->
        object.valid = false for object in @dependingObjects
        @valid = false    

    # Forces calculation on the called object. After this function is called the object has to be in proper valid state.
    forceCalculate: ->    
        # End prematurely if we are allready in a valid state
        return true if @valid
        
        # We are in an invalid state, so assume we are not virtual
        @virtual = false
        
        # First, let all the parents in the tree calculate themselves.
        for parent in @parents
            parent.forceCalculate()
            
            # As soon as one of the parents turnsout to be virtual, we set ourselves to virutal and ignore the other parents
            if parent.virtual
              @virtual = true
              break
        
        # End prematurely if we turn out to be virtual
        return true if @virtual
        
        # Call the instance implemented calculate function to do the actual calculation
        @calculate()
        
        @valid = true
        return true

    # Instance implemented calculate function. Does the actual calculation logic
    calculate: -> # mock implementation
    
    calculateRoots: ->
      if @parents.length == 0
        [this]
      else
        all_roots = []
        
        for parent in @parents
          for root in parent.roots
            all_roots.push root
        
        reduced_roots = []
        for root, i in all_roots
          if (all_roots.indexOf root) == i
            reduced_roots.push root
                
        reduced_roots
    
    calculateAncestors: ->
        ancestors = []
        ancestors = ancestors.concat @parents # our parents are ancestors
        ancestors = ancestors.concat parent.ancestors for parent in @parents # the ancestors of our parents are ancestors
        ancestors = Entity.unique ancestors # now filter out duplicate entities

        return ancestors
    
    sameRoots: (other) ->
        return false if this.roots.length != other.roots.length
        
        items = {}
        
        items[item] = 1 for item in this.roots
        
        for item in other.roots
          if not items[item]?
            return false
            
          items[item]++
        
        for item in items
          if item != 2
            return false
        
        return true

class Point extends Entity
    type: "Point"

    hits: (obj) -> distance(obj, this) < Settings.point.hit_radius
    
    equal: (other) -> other.laysOn this

    boundedBy: (a, b) -> between(a.x, @x, b.x) and between(a.y, @y, b.y)

    laysOn: (obj) ->
        switch
            when obj instanceof Point
                s = 1/@space.box.scale
                feq(obj.x, @x, s) and feq(obj.y, @y, s)
            when obj instanceof Circle then feq(distance(obj, this), obj.r)
            when obj instanceof Line
                c1 = 0.99 < (a = dydx(obj.p1, this))/(b = obj.rc) < 1.01 or
                     (a == 0 == b and feq(obj.p1.y, @y)) or
                     (abs(a) == Infinity == abs(b) and feq(obj.p1.x, @x))
                
                c2 = 0.99 < (a = dydx(obj.p2, this))/(b = obj.rc) < 1.01 or 
                     (a == 0 == b and feq(obj.p2.y, @y)) or
                     (abs(a) == Infinity == abs(b) and feq(obj.p2.x, @x))

                return c1 or c2
            else throw new Error("Invalid argument to Point.laysOn | #{a}")

class DependentPoint extends Point
    constructor: (@o1, @o2, @i) ->
        @initialize([o1, o2])
        @destroy() if @o1 == @o2
        @method = Intersection.method(@o1, @o2)
        @hidden = @o1.hidden or @o2.hidden
        
    calculate: ->      
        {@x, @y, @virtual} = @method(@i)
    
    free: false

class FreePoint extends Point
    @attr "x",
        set: (v) ->
            @_x = v
            v
            
        get: -> @_x
        
    @attr "y",
        set: (v) ->
            @_y = v
            @invalidate()
            v
            
        get: -> @_y
        
    constructor: (x, y, @space) ->
        @initialize([], @space)
        
        @x = x
        @y = y
        
    free: true

class Line extends Entity
    equal: (other) -> (other.p1.equal(this.p1) and other.p2.equal(this.p2)) or (other.p1.equal(this.p2) and other.p2.equal(this.p1))

    boundedBy: (a, b) -> (between(a.x, @p1.x, b.x) and between(a.y, @p1.y, b.y)) or (between(a.x, @p2.x, b.x) and between(a.y, @p2.y, b.y))

    type: "Line"

    @attr "x1"
        set: (v) -> @p1.x = v; v
        get: -> @p1.x
        
    @attr "y1"
        set: (v) -> @p1.y = v; v
        get: -> @p1.y
    
    @attr "x2"
        set: (v) -> @p2.x = v; v
        get: -> @p2.x
        
    @attr "y2"
        set: (v) -> @p2.y = v; v
        get: -> @p2.y

    @attr "extended",
        set: (v) -> 
            @_extended = v
            @invalidate()
            v
            
        get: -> @_extended

    @raw = class extends this
        constructor: (@p1, @p2) ->

    constructor: (@p1, @p2) ->
        @initialize([@p1, @p2])
        @destroy() if @p1 == @p2
        @extended = false
        
    calculate: ->
        @rc = dydx(@p1, @p2)
        @hc = @p1.y - @rc * @p1.x
        @length = sqrt(sq(@x2-@x1)+sq(@y2-@y1))
        @vertical = Math.abs(@rc) == Infinity

class Circle extends Entity
    equal: (other) -> other.p1.equal(this.p1) and other.p2.laysOn(this)

    boundedBy: (a, b) -> between(a.x, @p1.x, b.x) and between(a.y, @p1.y, b.y)

    type: "Circle"

    constructor: (@p1, @p2) ->
        @initialize([@p1, @p2])
        @destroy() if @p1 == @p2
    
    @raw = class extends this
        constructor: (@x, @y, @r) ->
        @::p1 = @::p2 =
            laysOn: -> false

    calculate: ->
        @x = @p1.x
        @y = @p1.y
        @r = distance(@p1, @p2)
        @angle = atan2(@p2.y-@p1.y, @p2.x-@p1.x)

globalize {Point, DependentPoint, FreePoint, Circle, Line}
