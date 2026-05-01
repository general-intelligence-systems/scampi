# Exceptions and Flow Control

Scampi can assert on exceptions, throws, and state changes.

## Raising Exceptions

Wrap the code in a lambda and call `.should.raise`:

```ruby
lambda { raise "boom" }.should.raise
lambda { raise "boom" }.should.raise(RuntimeError)
lambda { 1 + 1 }.should.not.raise
```

## Throwing Values

Test that a symbol is thrown:

```ruby
lambda { throw :halt }.should.throw(:halt)
```

## Detecting Change

Assert that a block changes the result of an expression:

```ruby
i = 0
lambda { i += 1 }.should.change { i }
```
