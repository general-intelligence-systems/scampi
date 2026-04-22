module Kernel
  # Conditionally run a test block.
  #
  # When placed in a Ruby file, the block is executed only when the file is
  # run directly (ruby myfile.rb) or when ENV["TEST"] is set to "true".
  # This lets you co-locate tests alongside implementation code.
  #
  #   # mylib.rb
  #   def greet(name) = "hello #{name}"
  #
  #   test do
  #     describe "greet" do
  #       it "says hello" do
  #         greet("world").should == "hello world"
  #       end
  #     end
  #   end
  #
  def test(&block)
    loc = caller_locations(1, 1).first
    caller_file = loc.absolute_path || loc.path

    if ENV["TEST"] == "true"
      require_relative '../scampi' unless defined?(Scampi)
      Scampi.summary_on_exit
      block.call
    elsif caller_file && $0
      program = File.expand_path($0) rescue $0
      caller_expanded = File.expand_path(caller_file) rescue caller_file
      if caller_expanded == program
        require_relative '../scampi' unless defined?(Scampi)
        Scampi.summary_on_exit
        block.call
      end
    end
  end
  private :test
end
