# Co-Located Tests

Scampi lets you place tests alongside your implementation code using the `test` block. The block only executes when the file is run directly or via the `scampi` CLI.

## How It Works

Wrap your specs in a `test do ... end` block at the bottom of any Ruby file:

```ruby
# greet.rb
def greet(name) = "hello #{name}"

test do
  describe "greet" do
    it "says hello" do
      greet("world").should == "hello world"
    end
  end
end
```

The test block runs when:

- The file is executed directly with `ruby greet.rb`
- The `scampi` CLI discovers it (via `rg`) and loads it with `ENV["TEST"]` set to `"true"`

When the file is required as a library (`require "greet"`), the test block is skipped entirely.

## Describe Blocks and Nesting

Use `describe` to group related specs into TAP subtests. You can nest them:

```ruby
test do
  describe "String" do
    describe "#upcase" do
      it "converts to uppercase" do
        "hello".upcase.should == "HELLO"
      end
    end
  end
end
```

## Before and After Hooks

Set up and tear down state with `before` and `after`:

```ruby
test do
  describe "stack" do
    before do
      @stack = []
    end

    it "starts empty" do
      @stack.should.be.empty
    end

    it "pushes items" do
      @stack.push(1)
      @stack.should.include 1
    end
  end
end
```

## Shared Contexts

Define reusable spec groups with `shared` and include them with `behaves_like`:

```ruby
shared "enumerable" do
  it "responds to each" do
    @collection.should.respond_to :each
  end
end

test do
  describe "Array" do
    before { @collection = [1, 2, 3] }
    behaves_like "enumerable"
  end
end
```
