# Assertions

Scampi provides a chainable `.should` DSL for assertions. Every assertion is counted as a TAP requirement.

## Equality and Matching

```ruby
greeting = greet("world")

greeting.should == "hello world"
greeting.should.equal "hello world"
greeting.should =~ /hello/
greeting.should.match(/hello/)
```

## Negation

Chain `.not` to negate any assertion. It can be placed anywhere in the chain:

```ruby
greeting.should.not == "goodbye"
greeting.should.not.match(/goodbye/)
```

## Predicates

Any predicate method (ending in `?`) can be used directly. Scampi auto-appends the `?`:

```ruby
[].should.be.empty
nil.should.be.nil
true.should.be.true
false.should.be.false
```

## Type Checks

```ruby
"hello".should.be.kind_of String
"hello".should.be.instance_of String
"hello".should.respond_to :upcase
```

## Identity

Test object identity (same object in memory):

```ruby
s = "hello"
s.should.be.identical_to s
s.should.be.same_as s
```

## Comparisons

```ruby
5.should.be > 3
5.should.be >= 5
3.should.be < 5
5.should.be <= 5
```

## Collections

```ruby
[1, 2, 3].should.include 2
```

## Numeric Closeness

Test that a number is within a delta of an expected value:

```ruby
3.14.should.be.close 3.1, 0.05
```

## Custom Matchers

Pass a lambda or proc to `.be.a` (or `.be.an`). The object under test is yielded to the block:

```ruby
palindrome = lambda { |obj| obj == obj.reverse }
"racecar".should.be.a palindrome
```

## Satisfy

For arbitrary conditions, use `.satisfy` with a block:

```ruby
10.should.satisfy { |n| n.even? }
```
