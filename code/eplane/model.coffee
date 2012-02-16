# The Entity class is the parent class for all the algebraic structures that live on the euclidean plane.
# It mainly contains entity hierachy (which entity depends on which). And general behaviour (hidability, recycling)
class Entity
    id_pool = 0
  
    @attr "visible" # Visibility is wheter the element is to be drawn
        get: -> not @virtual and not @hidden and not @destroyed
        
    @unique: `function(arr) {
        var hash = {}, result = [];
        for ( var i = 0, l = arr.length; i < l; ++i ) {
            if ( !hash.hasOwnProperty(arr[i].id) ) { //it works with objects! in FF, at least
                hash[ arr[i].entity_id ] = true;
                result.push(arr[i]);
            }
        }
        return result;
    }`    
    
    # We initialize objects to set properies that are to be used by the instances of entity.
    initialize: (parents=[]) ->
        throw new Error "Allready initialized" if @finalized? and @finalized == true

        # Hierachy        
        @children = []
        @parents = []
        for parent in parents
          @parents.push parent
          parent.addChild this
          
        @dependingObjects = []
        @ancestors        = @calculateAncestors()
        @roots            = @calculateRoots()
        
        # Logical state
        @valid      = false
        @destroyed  = false
        @virtual    = false
        
        # Misc state, used by the drawing engine
        @hidden     = false
        @selected   = false
        @hover      = false
        
        @name = null
        
        @id = id_pool++
        
    destroy: ->
        if @parents?
          p.removeChild this for p in @parents
          @parents = []
        
        if @children?
          child.destroy() for child in @children
          @children = []
            
        @destroyed = true
    
    addChild: (c) ->
        if @destroyed
          c.destroy()
          return false
      
        @children.push c
        @dependingObjects.push c
        for object in @ancestors
          object.dependingObjects.push c
    
    removeChild: (t) -> @children = @children.filter (c) -> c != t
    
    # Invalidate the entity, forcing recalculation when necessary
    invalidate: ->
        @valid = false
        
        depending_objects = @calculateDependingObjects()
        for depending_object in depending_objects
            depending_object.valid = false

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
    
    calculateDependingObjects: -> @dependingObjects
    
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

class BasePoint extends Entity
    hits: (obj) -> distance(obj, this) < Settings.point.hit_radius
    
    laysOn: (obj) ->
        switch
            when obj instanceof Circle
                return (obj.r - sml) < distance(this, obj) < (obj.r + sml)
            when obj instanceof Line
                c1 = 0.99 < dydx(obj.p1, this)/obj.rc < 1.01
                c2 = 0.99 < dydx(obj.p2, this)/obj.rc < 1.01
            
                return c1 or c2
            else
                console.log a
                throw new Error("Invalid argument to Point.laysOn | #{a}")

class Point extends BasePoint
    constructor: (@o1, @o2, @i) ->
        @initialize([o1, o2])
        @destroy() if @o1 == @o2
        @method = Intersection.method(@o1, @o2)
        
    calculate: ->      
        {@x, @y, @virtual} = @method(@o1, @o2, @i)
    
    free: false

class FreePoint extends BasePoint
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
        
    constructor: (x, y) ->
        @initialize()
        
        @x = x
        @y = y
        
    free: true

class Line extends Entity
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
    constructor: (@p1, @p2) ->
        @initialize([@p1, @p2])
        @destroy() if @p1 == @p2
        
    calculate: ->
        @x = @p1.x
        @y = @p1.y
        @r = distance(@p1, @p2)
        @angle = atan2(@p2.y-@p1.y, @p2.x-@p1.x)

globalize {Point, FreePoint, Circle, Line}
