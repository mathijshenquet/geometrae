# errors:
#    operand_invalid_msg: (op, pool, operand_name) -> "#{operand_name} of operation #{@op.summarize()} is not a valid member of pool `#{pool.summarize()}'"
#  
#  verifyBinary: (op, a, b) ->
#    unless a.pool == b.pool
#      throw new qNumError "Can't preform operations on numbers unless they have the same number pool (a.pool = `#{a.pool.summarize()}', b.pool = `#{b.pool.summarize()}')"
#    
#    pool = a.pool
#    
#    unless pool.isValid a
#      throw new qNumError @errors.operand_invalid_msg(op, pool, "Left hand operand")
#      
#    unless pool.isValid b
#      throw new qNumError @errors.operand_invalid_msg(op, pool, "Right hand operand")
#  
#  verifyUnary: (op, a) ->
#    unless a.pool.isValid a
#      throw new qNumError @errors.operand_invalid_msg(op, a.pool, "Operand")

{X, Q} = qNum

qNum.Ops = class qNumOps
  constructor: (@pool) ->
  
  # testing functions, returning booleans
  equals: (left, right) -> 
    switch left.type
      when X # a1 + b1 sqrt(q) == a2 + b2 sqrt(q) if a1 == a2 and b1 == b2 
        @equals(left.a, right.a) and @equals(left.b, right.b)
      
      when Q # fractions a/b == c/d if a * d == b * c -> a/b == b/a -> b*a == a*b 
        left.d * right.n == left.n * right.d
  
  # unary functions, mainly for utility
  
  # note: square could be implement with a -> multiply(a, a). But this is more efficient
  square: (number) ->
    switch number.type
      when X then new X @add( @square(number.a), @multiply(@square(number.b), @pool.domain[number.depth-1])), # a^2 + b^2 * alpha
                        @multiply(qNum.extend(2, (number.depth-1)), @multiply(number.a, number.b)) # 2 * a * b
      
      when Q then new Q (number.n*number.n), (number.d*number.d)
  
  trySqrt: (number) -> switch (number.type ? false)
    when X
      a = number.a
      b = number.b
      depth = number.depth
      domain = @pool.domain[depth-1]
  
      # We begin by deconstructing our number A into parts a and b. 
      #   A = a + b * sqrt(domain)
      #
      # We need to find sqrt(A). In order to do this lets find a number for which 
      #   A = (x + y * sqrt(domain))^2
      # 
      # Solving the above equations for x and y:
      #   a = x^2 + y^2 * domain
      #   b = 2*x*y
      #
      # Note that if b == 0 then x = 0 or y = 0 and thus that the solution for a becomes trivial:
      #   in case of x = 0 then a = y^2 * domain
      #   in case of y = 0 then a = x^2
      # 
      # This is the first branch of the code
      #
      # ... explain more
      #
      
      if @equals(b, qNum.zero(b.depth)) # b == 0
        if (y = @trySqrt @divide(a, domain))
          return new X qNum.zero(depth-1), y
        
        if (x = @trySqrt a)
          return new X x, qNum.zero(depth-1)
        
        return false
          
      else # b != 0
        _Delta = @subtract(@square(a), @multiply(@square(b), domain))
        
        return false unless (delta = @trySqrt _Delta)
          
        domain_2 = @add(domain, domain)
          
        _Y1 = @divide( @add(a, delta)
                     , domain_2
                     )
            
        _Y2 = @divide( @subtract(a, delta)
                     , domain_2
                     )
        
        return false unless (y = @trySqrt _Y1 or @trySqrt _Y2)
        
        x = @divide( @multiply( b , (qNum.extend (new Q 1, 2), (depth-1)) ), y)
        
        return new X x, y
      
    when Q
      if (n = @trySqrt number.n) and (d = @trySqrt number.d)
        return new Q n, d
      else
        return false
      
    else
      unless typeof number == 'number'
        throw new qNumError "Type error: try to sqrt a non number"
    
      root = Math.sqrt number
      if root % 1 == 0
        return root
      else
        return false
  
  sqrt: (number) ->
    if (root = @trySqrt number)
      return root
    else
      @pool.introduceExtension number
      return new X (qNum.zero @pool.domain.length-1), (qNum.one @pool.domain.length-1)
  
  neg: (number) ->
    switch number.type
      when X then new X @neg(number.a), @neg(number.b)
      when Q then new Q (-number.n), number.d
  
  reciprocal: (number) -> # blindly implemented from `Solving Geometrical Constraint Systems Using CLP Based on Linear Constraint Solver'
    switch number.type
      when X
        # when doing this sort of caching, make sure you .copy() when using the variable. Objects and arrays are still pass by reference in javascript
        delta = @subtract(
                  @square(number.a),
                  @multiply(
                    @square(number.b),
                    @pool.domain[number.depth-1]
                  )
                )
      
        new X @divide(number.a, delta.copy()), @divide(@neg(number.b), delta.copy())
      
      when Q # flip the denom. and numer. a/b -> b/a
        new Q number.d, number.n
    
  # the binary operators!
 
  add: (left, right) -> 
    #TODO debug/error reporting

    switch left.type
      when X # a1 + b1 * sqrt(q) + a2 + b2 * sqrt(q) -> (a1 + a2) + (b1 + b2) * sqrt(q)
        new X @add(left.a, right.a), @add(left.b, right.b)
      
      when Q # n1/d1 + n2/d2 is (n1*d2+n2*d1) / (d1*d2)
        new Q (left.n * right.d + right.n * left.d), (left.d * right.d)
        
  subtract: (left, right) -> 
    switch left.type
      when X
        new X @subtract(left.a, right.a), @subtract(left.b, right.b)
      when Q
        new Q (left.n * right.d - right.n * left.d), (left.d * right.d)
      
  multiply: (left, right) ->
    switch left.type
      when X
        new X @add(
                @multiply(left.a, right.a), 
                @multiply(
                  @multiply(left.b, right.b), 
                  @pool.domain[left.depth-1]
                )
              ),
              @add(
                @multiply(left.a, right.b), 
                @multiply(right.a, left.b)
              )
        
      when Q then new Q (left.n * right.n), (left.d * right.d)
          
  divide: (left, right) -> @multiply(left, @reciprocal(right))
  