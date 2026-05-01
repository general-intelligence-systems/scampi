module Scampi
  # The assertion wrapper returned by `Object#should`.
  #
  # Supports chainable assertions like `.should.be.empty`, `.should.not == 5`,
  # and `.should.be.a(matcher)`. Undefines predicate and operator methods from
  # Object so they can be intercepted via `method_missing`.
  class Should
    # Undefine predicate and operator methods so they route through method_missing.
    instance_methods.each { |name| undef_method name  if name =~ /\?|^\W+$/ }

    # Wrap an object for assertion.
    #
    # @parameter object [Object] The value under test.
    def initialize(object)
      @object = object
      @negated = false
    end

    # Toggle negation. Can be chained: `.should.not.be.empty`.
    #
    # @returns [Should] self, for chaining.
    def not(*args, &block)
      @negated = !@negated

      if args.empty?
        self
      else
        be(*args, &block)
      end
    end

    # Identity chain or custom matcher. With no arguments, returns self
    # for further chaining. With a block or lambda, delegates to `satisfy`.
    def be(*args, &block)
      if args.empty?
        self
      else
        unless block_given?
          block = args.shift
        end
        satisfy(*args, &block)
      end
    end

    alias a  be
    alias an be

    # Assert that the block returns truthy for the wrapped object.
    #
    # @parameter description [String] Failure message.
    # @returns [Boolean]
    def satisfy(description="", &block)
      r = yield(@object)
      if Scampi::Counter[:depth] > 0
        Scampi::Counter[:requirements] += 1
        raise Scampi::Error.new(:failed, description)  unless @negated ^ r
        r
      else
        @negated ? !r : !!r
      end
    end

    # Catch predicate calls and auto-append `?` to the method name.
    # For example, `.should.be.empty` becomes `.empty?` on the object.
    def method_missing(name, *args, &block)
      name = "#{name}?"  if name.to_s =~ /\w[^?]\z/

      desc = @negated ? "not ".dup : "".dup
      desc << @object.inspect << "." << name.to_s
      desc << "(" << args.map{|x|x.inspect}.join(", ") << ") failed"

      satisfy(desc) { |x| x.__send__(name, *args, &block) }
    end

    # Assert equality using `==`.
    #
    # @parameter value [Object]
    def equal(value) = self == value

    # Assert the object matches a pattern using `=~`.
    #
    # @parameter value [Regexp]
    def match(value) = self =~ value

    # Assert object identity (same object in memory).
    #
    # @parameter value [Object]
    def identical_to(value) = self.equal? value
    alias same_as identical_to

    # Unconditionally fail the current spec.
    #
    # @parameter reason [String] Failure message.
    def flunk(reason="Flunked")
      raise Scampi::Error.new(:failed, reason)
    end
  end
end
