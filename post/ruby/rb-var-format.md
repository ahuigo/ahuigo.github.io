---
title: rb var format
date: 2020-06-02
private: true
---
# rb var format
## var inline
    "Exception authorizing user: #{ex}"

## printf

    message = "Processing of the data has finished in %d seconds" % [time]
    puts "The average is %0.2f" % [score]

## var dump
类似go:`%#v`, python `%r`

    p var.inspect

# puts vs p vs print

    > class P
    >   def inspect(); "P#inspect"; end
    >   def to_s(); "P#to_s"; end
    > end
    > q = P.new

## print
print calls `to_s` on the object and spits it out to $stdout.

    > print q
    P#to_s

print does not append a new line.

    > print 1,2,3
    123 => nil

## puts
puts is similar to print – calling `to_s` – but adds a newline to the output.

    > puts q
    P#to_s
    => nil
    > puts 1,2,3
    1
    2
    3

## p
> p variable is a shortcut for puts variable.inspect
`p` adds a newline, but rather than calling to_s, p calls `inspect`.

    > p q
    P#inspect
    => P#inspect

p 会返回原值

    > p 1,2,3
    1
    2
    3
    => [1, 2, 3]
    > p '1'
    "1"
    => "1"
