module Scampi
  class Context
    attr_reader :name, :block

    def initialize(name, &block)
      @name = name
      @block = block
      @items = []
      @before = []
      @after = []
    end

    # Phase 1: evaluate block to discover specs and children.
    # Nothing is executed — it and describe just queue.
    def register
      tap do
        if name =~ RestrictContext
          instance_eval(&block)
        else
          self
        end
      end
    end

    # Count total specs recursively.
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
    # +indent+ is the nesting depth (0 = inside a top-level describe).
    # Returns true if all specs/children passed, false otherwise.
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

    def before(&block); @items << [:before, block]; @before << block; end
    def after(&block);  @items << [:after, block];  @after  << block; end

    def behaves_like(*names)
      names.each { |name| instance_eval(&Shared[name]) }
    end

    def it(description, &block)
      return  unless description =~ RestrictName
      block ||= proc { should.flunk "not implemented" }
      @items << [:spec, description, block]
    end

    def should(*args, &block)
      if Counter[:depth] == 0
        it('should ' + args.first, &block)
      else
        super(*args, &block)
      end
    end

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

    def raise?(*args, &block) = block.raise?(*args)
    def throw?(*args, &block) = block.throw?(*args)
    def change?(&block) = lambda{}.change?(&block)
  end
end
