# Scampi

A small Ruby test framework forked from [Bacon](https://github.com/chneukirchen/bacon) with built-in [TAP (Test Anything Protocol)](https://testanything.org/) output.

## Requirements

- Ruby >= 3.3
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) — used to find test files

## Usage

Tests can live alongside your code in an `__END__` section — the specs never
load in production (Ruby stops parsing at `__END__`), and `scampi` picks them up:

```ruby
# greet.rb
def greet(name) = "hello #{name}"

__END__

greeting = proc { |name| greet(name) }
describe "greet" do
  it "equality and matching" do
    greeting.("world").should == "hello world"
  end
end
```


```ruby
describe "greet" do
  it "equality and matching" do
    greeting.("world").should == "hello world"
    greeting.("world").should.equal "hello world"
    greeting.("world").should =~ /hello/
    greeting.("world").should.match(/hello/)
  end

  it "negation" do
    greeting.("world").should.not == "goodbye"
    greeting.("world").should.not.match(/goodbye/)
  end

  it "predicates" do
    [].should.be.empty
    nil.should.be.nil
    true.should.be.true
    false.should.be.false
  end

  it "type checks" do
    "hello".should.be.kind_of String
    "hello".should.be.instance_of String
    "hello".should.respond_to :upcase
  end

  it "identity" do
    s = "hello"
    s.should.be.identical_to s
    s.should.be.same_as s
  end

  it "comparisons" do
    5.should.be > 3
    5.should.be >= 5
    3.should.be < 5
    5.should.be <= 5
  end

  it "collections" do
    [1, 2, 3].should.include 2
  end

  it "numeric closeness" do
    3.14.should.be.close 3.1, 0.05
  end

  it "custom matchers" do
    palindrome = lambda { |obj| obj == obj.reverse }
    "racecar".should.be.a palindrome
  end

  it "satisfy" do
    10.should.satisfy { |n| n.even? }
  end

  describe "exceptions and flow" do
    it "raises" do
      lambda { raise "boom" }.should.raise
      lambda { raise "boom" }.should.raise(RuntimeError)
      lambda { 1 + 1 }.should.not.raise
    end

    it "throws" do
      lambda { throw :halt }.should.throw(:halt)
    end

    it "detects change" do
      i = 0
      lambda { i += 1 }.should.change { i }
    end
  end
end
```

Run a file (or let `scampi` auto-discover every `.rb` with an `__END__` spec section):

```
$ scampi greet.rb
$ scampi
```

## GitHub Actions

```yaml
name: Test

on: [push, pull_request]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - run: sudo apt-get install -y ripgrep

      - run: bundle exec scampi
```
