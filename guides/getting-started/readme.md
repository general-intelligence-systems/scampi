# Getting Started

This guide walks you through installing Scampi and writing your first test.

## Requirements

- Ruby >= 3.3
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) -- used to discover test files

## Installation

Add Scampi to your Gemfile:

```ruby
gem "scampi"
```

Or install it directly:

```sh
gem install scampi
```

## Writing Your First Test

Create a file called `greet.rb`:

```ruby
def greet(name) = "hello #{name}"

test do
  it "greets by name" do
    greet("world").should == "hello world"
  end
end
```

Run it directly:

```sh
ruby greet.rb
```

Or with the `scampi` runner:

```sh
scampi greet.rb
```

## Running All Tests

When invoked without arguments, `scampi` uses `rg` to find every file containing a `test do` block and runs them all:

```sh
bundle exec scampi
```
