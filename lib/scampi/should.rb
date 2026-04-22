module Scampi
  class Should
    # Kills ==, ===, =~, eql?, equal?, frozen?, instance_of?, is_a?,
    # kind_of?, nil?, respond_to?, tainted?
    instance_methods.each { |name| undef_method name  if name =~ /\?|^\W+$/ }

    def initialize(object)
      @object = object
      @negated = false
    end

    def not(*args, &block)
      @negated = !@negated

      if args.empty?
        self
      else
        be(*args, &block)
      end
    end

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

    def method_missing(name, *args, &block)
      name = "#{name}?"  if name.to_s =~ /\w[^?]\z/

      desc = @negated ? "not ".dup : "".dup
      desc << @object.inspect << "." << name.to_s
      desc << "(" << args.map{|x|x.inspect}.join(", ") << ") failed"

      satisfy(desc) { |x| x.__send__(name, *args, &block) }
    end

    def equal(value) = self == value
    def match(value) = self =~ value

    def identical_to(value) = self.equal? value
    alias same_as identical_to

    def flunk(reason="Flunked")
      raise Scampi::Error.new(:failed, reason)
    end
  end
end
