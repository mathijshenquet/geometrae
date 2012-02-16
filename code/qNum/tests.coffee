
pool = new qNumPool

c = pool.calculate()

result = pool.calculate()
             .introduce(10)
             .introduce(7)
             .divide()
             .store()

c = c.destroy()


tests =
  basic: (pool) ->
    a = pool.calculate()
      .introduce(11)
      .introduce(7)
      .divide()
      .store()
      
    b = pool.calculate()
      .introduce(7)
      .introduce(11)
      .divide()
      .store()
      
    console.log "#{a} | #{b}"
    
    pool.introduceExtension new Q 2, 1
    
    c = pool.calculate()
      .load(a)
      .load(b)
      .multiply()
      .store()

  
    console.log "#{a} * #{b} + #{c}"
  
  book: (pool) ->
    a = pool.begin()
      .introduce(2)
      .sqrt()
      .introduce(3)
      .sqrt()
      .add()
      .store()
    
    b = pool.begin()
      .introduce(6)
      .sqrt()
      .introduce(2)
      .multiply()
      .introduce(5)
      .add()
      .sqrt()
      .store()

    console.log "#{a} | #{b}"

  frac: (pool) ->
    console.log pool.begin()
      .introduce(7)
      .introduce(11)
      .divide()
      .introduce(7)
      .introduce(11)
      .divide()
      .subtract()
      .store()

tests.book new Pool