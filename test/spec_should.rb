require File.expand_path('../../lib/scampi', __FILE__)

describe "#should shortcut for #it('should')" do
  
  should "be called" do
    @called = true
    @called.should.be == true
  end
  
  should "save some characters by typing should" do
    lambda { should.satisfy { 1 == 1 } }.should.not.raise
  end

  should "save characters even on failure" do
    lambda { should.satisfy { 1 == 2 } }.should.raise Scampi::Error
  end

  should "work nested" do
    should.satisfy {1==1}
  end
  
  should "add new specifications" do
    # verify the counter increments for each spec
    Scampi::Counter[:specifications].should.be > 0
  end

  should "have been called" do
    @called.should.be == true
  end

end
