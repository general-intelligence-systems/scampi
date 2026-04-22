class Object
  def true?  = false
  def false? = false
end

class TrueClass
  def true? = true
end

class FalseClass
  def false? = true
end

class Proc
  def raise?(*exceptions)
    call
  rescue *(exceptions.empty? ? RuntimeError : exceptions) => e
    e
  else
    false
  end

  def throw?(sym)
    catch(sym) {
      call
      return false
    }
    return true
  end

  def change?
    pre_result = yield
    call
    post_result = yield
    pre_result != post_result
  end
end

class Numeric
  def close?(to, delta)
    (to.to_f - self).abs <= delta.to_f  rescue false
  end
end

class Object
  def should(*args, &block)
    Scampi::Should.new(self).be(*args, &block)
  end
end

module Kernel
  private

  def describe(*args, &block)
    Scampi.queue << Scampi::Context.new(args.join(' '), &block)
  end

  def shared(name, &block)
    Scampi::Shared[name] = block
  end
end
