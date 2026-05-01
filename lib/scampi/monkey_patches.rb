# Predicate extensions for truth testing.
class Object
  # @returns [Boolean] Always false for non-boolean objects.
  def true?  = false

  # @returns [Boolean] Always false for non-boolean objects.
  def false? = false
end

class TrueClass
  # @returns [Boolean] True.
  def true? = true
end

class FalseClass
  # @returns [Boolean] True.
  def false? = true
end

class Proc
  # Call the proc and check whether it raises one of the given exceptions.
  #
  # @parameter exceptions [Array(Class)] Exception classes to catch (defaults to RuntimeError).
  # @returns [Exception | Boolean] The caught exception, or false if none was raised.
  def raise?(*exceptions)
    call
  rescue *(exceptions.empty? ? RuntimeError : exceptions) => e
    e
  else
    false
  end

  # Call the proc and check whether it throws the given symbol.
  #
  # @parameter sym [Symbol] The symbol to catch.
  # @returns [Boolean]
  def throw?(sym)
    catch(sym) {
      call
      return false
    }
    return true
  end

  # Call the proc and check whether it changes the result of the given block.
  #
  # @returns [Boolean]
  def change?
    pre_result = yield
    call
    post_result = yield
    pre_result != post_result
  end
end

class Numeric
  # Check whether this number is within `delta` of `to`.
  #
  # @parameter to [Numeric] The target value.
  # @parameter delta [Numeric] The allowed deviation.
  # @returns [Boolean]
  def close?(to, delta)
    (to.to_f - self).abs <= delta.to_f  rescue false
  end
end

class Object
  # Create a {Scampi::Should} wrapper for this object.
  #
  # @returns [Scampi::Should]
  def should(*args, &block)
    Scampi::Should.new(self).be(*args, &block)
  end
end

module Kernel
  private

  # Create a top-level test context. Adds a {Scampi::Context} to the global queue.
  def describe(*args, &block)
    Scampi.queue << Scampi::Context.new(args.join(' '), &block)
  end

  # Register a shared context block by name for use with `behaves_like`.
  #
  # @parameter name [String] The shared context name.
  def shared(name, &block)
    Scampi::Shared[name] = block
  end

  # Allow `it` at the top level (outside a describe block).
  # Stored as a raw spec — only `describe` creates subtests.
  def it(description, &block)
    block ||= proc { should.flunk "not implemented" }
    Scampi.queue << [:spec, description, block]
  end
end
