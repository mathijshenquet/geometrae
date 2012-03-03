globalize Math

global.sml = 0.1
global.TAU = PI * 2
global.HALF_TAU = PI
global.distance = (a, b) -> sqrt(sq(a.x-b.x)+sq(a.y-b.y))
global.sq = (a) -> a*a

global.between = (a, b, c) ->
  unless a < c
    [a, c] = [c, a]

  a < b < c

global.Random =
    int: (min, max) -> floor(Math.random() * (max - min + 1)) + min
    double: (min, max) -> Math.random() * (max  o- min) + min
    bool: -> Math.random(0,1) > 0.5
    
global.sgn = (x) -> if (x < 0) then -1 else 1

global.repeat = (pattern, count) ->
    return '' if count < 1
    result = ''
    while count > 0
        if count & 1
            result += pattern
        
        count >>= 1
        pattern += pattern
    
    result

global.pad = (n, char, str) ->
    pl = n - str.length
    str + repeat(char, pl)
    
global.dy   = (a, b) -> b.y - a.y
    
global.dx   = (a, b) -> b.x - a.x
    
global.dydx = (a, b) -> (b.y - a.y)/(b.x - a.x)
    
# This file contains the common helper functions that we'd like to share among
# the **Lexer**, **Rewriter**, and the **Nodes**. Merge objects, flatten
# arrays, count characters, that sort of thing.

# Peek at the beginning of a given string to see if it matches a sequence.
global.starts = (string, literal, start) ->
  literal is string.substr start, literal.length

# Peek at the end of a given string to see if it matches a sequence.
global.ends = (string, literal, back) ->
  len = literal.length
  literal is string.substr string.length - len - (back or 0), len

# Trim out all falsy values from an array.
global.compact = (array) ->
  item for item in array when item

# Count the number of occurrences of a string in a string.
global.count = (string, substr) ->
  num = pos = 0
  return 1/0 unless substr.length
  num++ while pos = 1 + string.indexOf substr, pos
  num

# Merge objects, returning a fresh copy with attributes from both sides.
# Used every time `Base#compile` is called, to allow properties in the
# options hash to propagate down the tree without polluting other branches.
global.merge = (options, overrides) ->
  extend (extend {}, options), overrides

# Extend a source object with the properties of another object (shallow copy).
global.extend = extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

# Return a flattened version of an array.
# Handy for getting a list of `children` from the nodes.
global.flatten = flatten = (array) ->
  flattened = []
  for element in array
    if element instanceof Array
      flattened = flattened.concat flatten element
    else
      flattened.push element
  flattened

# Delete a key from an object, returning the value. Useful when a node is
# looking for a particular method in an options hash.
global.del = (obj, key) ->
  val =  obj[key]
  delete obj[key]
  val

# Gets the last item of an array(-like) object.
global.last = (array, back) -> array[array.length - (back or 0) - 1]
