# Scampi

A small Ruby test framework forked from [Bacon](https://github.com/chneukirchen/bacon) with built-in [TAP (Test Anything Protocol)](https://testanything.org/) output.

## Usage

```ruby
# test/my_test.rb
require 'scampi'

describe 'Array' do
  before do
    @ary = []
  end

  it 'should be empty' do
    @ary.should.be.empty
    @ary.size.should.equal 0
  end

  it 'should raise on bad index' do
    lambda { @ary.fetch(0) }.should.raise(IndexError)
  end
end
```

Run it:

```
$ scampi test/my_test.rb
```
