module Scampi
  # A test context created by `describe`. Holds specs, hooks, and child contexts.
  #
  # Operates in two phases:
  # 1. **Register** -- evaluates the block to discover `it` specs and nested children.
  # 2. **Execute** -- runs all registered specs in order, emitting TAP subtests.
  class Context
    # @attribute [String] The context name (passed to `describe`).
    attr_reader :name

    # @attribute [Proc] The block that defines this context's specs and children.
    attr_reader :block

    # Create a new context.
    #
    # @parameter name [String] The describe block's label.
    def initialize(name, &block)
      @name = name
      @block = block
      @items = []
      @before = []
      @after = []
    end

    # Phase 1: evaluate block to discover specs and children.
    # Nothing is executed -- `it` and `describe` just queue items.
    def register
      tap do
        if name =~ RestrictContext
          instance_eval(&block)
        else
          self
        end
      end
    end

    # Count total specs recursively across this context and its children.
    #
    # @returns [Integer]
    def count
      @items.sum { |item|
        case item[0]
        when :spec  then 1
        when :child then item[1].count
        else 0
        end
      }
    end

    # Phase 2: run all registered specs in order, emitting TAP subtests.
    #
    # @parameter indent [Integer] Nesting depth (0 = inside a top-level describe).
    # @returns [Boolean] Whether all specs and children passed.
    def execute(indent = 0)
      prefix = "    " * indent
      inner  = "    " * (indent + 1)

      plan = @items.count { |item| item[0] == :spec || item[0] == :child }

      puts "#{prefix}# Subtest: #{@name}"
      puts "#{inner}1..#{plan}"

      befores = []
      afters  = []
      local_n = 0
      all_passed = true

      @items.each { |item|
        case item[0]
        when :before
          befores << item[1]
        when :after
          afters << item[1]
        when :spec
          Counter[:specifications] += 1
          local_n += 1
          passed = run_requirement(item[1], item[2], befores, afters, indent + 1, local_n)
          all_passed = false  unless passed
        when :child
          local_n += 1
          child_passed = item[1].execute(indent + 1)
          if child_passed
            puts "#{inner}#{"ok".green} #{local_n} - #{item[1].name}"
          else
            puts "#{inner}#{"not ok".red} #{local_n} - #{item[1].name}"
          end
          all_passed = false  unless child_passed
        end
      }

      all_passed
    end

    # Register a before hook that runs before each spec in this context.
    def before(&block); @items << [:before, block]; @before << block; end

    # Register an after hook that runs after each spec in this context.
    def after(&block);  @items << [:after, block];  @after  << block; end

    # Include shared context blocks by name.
    #
    # @parameter names [Array(String)] Names of shared contexts to include.
    def behaves_like(*names)
      names.each { |name| instance_eval(&Shared[name]) }
    end

    # Define a spec within this context.
    #
    # @parameter description [String] What this spec asserts.
    def it(description, &block)
      return  unless description =~ RestrictName
      block ||= proc { should.flunk "not implemented" }
      @items << [:spec, description, block]
    end

    # When called at the context level (outside a spec body), acts as a
    # shortcut for `it('should ...')`. Inside a spec body, delegates to
    # the standard `Object#should`.
    def should(*args, &block)
      if Counter[:depth] == 0
        it('should ' + args.first, &block)
      else
        super(*args, &block)
      end
    end

    # Run a single spec with before/after hooks and emit TAP output.
    #
    # @parameter description [String] Spec description.
    # @parameter spec [Proc] The spec body.
    # @parameter befores [Array(Proc)] Before hooks to run.
    # @parameter afters [Array(Proc)] After hooks to run.
    # @parameter indent [Integer] TAP indentation depth.
    # @parameter local_n [Integer] Spec number within this context.
    # @returns [Boolean] Whether the spec passed.
    def run_requirement(description, spec, befores, afters, indent = 0, local_n = 1)
      Scampi.handle_requirement(description, indent, local_n) do
        begin
          Counter[:depth] += 1
          rescued = false
          begin
            befores.each { |block| instance_eval(&block) }
            prev_req = Counter[:requirements]
            instance_eval(&spec)
          rescue Object => e
            rescued = true
            raise e
          ensure
            if Counter[:requirements] == prev_req and not rescued
              raise Error.new(:missing,
                              "empty specification: #{@name} #{description}")
            end
            begin
              afters.each { |block| instance_eval(&block) }
            rescue Object => e
              raise e  unless rescued
            end
          end
        rescue SystemExit, Interrupt
          raise
        rescue Object => e
          ErrorLog << "#{e.class}: #{e.message}\n"
          e.backtrace.find_all { |line| line !~ /bin\/scampi|\/scampi\.rb:\d+/ }.
            each_with_index { |line, i|
            ErrorLog << "\t#{line}#{i==0 ? ": #@name - #{description}" : ""}\n"
          }
          ErrorLog << "\n"

          if e.kind_of? Error
            Counter[e.count_as] += 1
            e.count_as.to_s.upcase
          else
            Counter[:errors] += 1
            "ERROR: #{e.class}"
          end
        else
          ""
        ensure
          Counter[:depth] -= 1
        end
      end
    end

    # Create a nested child context (TAP subtest).
    #
    # Methods defined on the parent context are copied to the child so
    # helper methods remain accessible.
    def describe(*args, &block)
      context = Scampi::Context.new(args.join(' '), &block)
      (parent_context = self).methods(false).each { |e|
        (class << context; self; end).send(:define_method, e) { |*args2, &block2|
          parent_context.send(e, *args2, &block2)
        }
      }
      @before.each { |b| context.before(&b) }
      @after.each  { |b| context.after(&b) }
      context.register
      @items << [:child, context]
      context
    end

    # Assert that the block raises an exception.
    def raise?(*args, &block) = block.raise?(*args)

    # Assert that the block throws a symbol.
    def throw?(*args, &block) = block.throw?(*args)

    # Assert that the block changes the result of an expression.
    def change?(&block) = lambda{}.change?(&block)
  end
end
