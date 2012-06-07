#!/usr/bin/env ruby

# First Ruby exercise:
# http://www.stanford.edu/class/cs106x/documents/02-sharing-chocolate.pdf

module Chocolate

  @@partitions = Hash.new
  @@divide = Hash.new

  def Chocolate.go(inp)
    puts "Reading #{inp}"
    bars = []
    File.open(inp, 'r') do |f|
      bars = f.readlines().each_slice(2)
    end
    bars.map {|b| divide b}
  end

  def Chocolate.inp_to_ints(inp)
    return inp.strip.split(" ").map { |d| Integer(d) }
  end

  def Chocolate.memoized_partitions
    @@partitions
  end

  def Chocolate.partitions(pieces)
    key = "#{pieces.sort}"
    if @@partitions[key] != nil
      return @@partitions[key]
    end

    if pieces.length == 2
      ret = [[[pieces[0]], [pieces[1]]]]
      @@partitions[key] = ret
      return ret
    end

    first = pieces[0]
    ps = partitions(pieces.slice(1, pieces.length))
    new_ps = []
    for p in ps
      new_ps << [p[0] + [first], p[1]]
      new_ps << [p[0], p[1] + [first]]
    end
    new_ps << [[first], pieces.slice(1, pieces.length)]

    @@partitions[key] = new_ps
    return new_ps
  end  

  def Chocolate.sum(l)
    l.inject(0, :+)
  end

  def Chocolate.divide(bar)
    dims = inp_to_ints bar[0]
    pieces = inp_to_ints bar[1]
    return _divide(dims[0], dims[1], pieces)
  end

  def Chocolate.memoized_divide
    @@divide
  end

  def Chocolate._divide(m, n, pieces)
    if m < n
      key = "#{[m, n, pieces.sort]}"
    else
      key = "#{[n, m, pieces.sort]}"
    end
    if @@divide[key] != nil
      return @@divide[key]
    end

    if sum(pieces) != m*n
      @@divide[key] = false
      return false
    end

    if pieces.length == 1
      if m*n == pieces[0]
        ret = true
      else
        ret = false
      end
      @@divide[key] = ret
      return ret
    end

    solvable = false
    for ps in partitions(pieces)
      p1 = ps[0]
      p2 = ps[1]

      for i in 1..m
        if (_divide(i, n, p1) and 
            _divide(m-i, n, p2)) or 
            (_divide(i, n, p2) and 
             _divide(m-i, n, p1))
          solvable = true
        end
      end

      for i in 1..n
        if (_divide(m, i, p1) and
            _divide(m, n-i, p2)) or 
            (_divide(m, i, p2) and
             _divide(m, n-i, p1))
          solvable = true
        end
      end
    end

    @@divide[key] = solvable
    return solvable
  end
end

