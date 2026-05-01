module Scampi
  # Custom exception used internally to signal spec failures and missing
  # assertions. The `count_as` attribute determines whether the error
  # increments the `:failed` or `:missing` counter.
  class Error < RuntimeError
    # @attribute [Symbol] Either `:failed` or `:missing`.
    attr_accessor :count_as

    # @parameter count_as [Symbol] What counter to increment (`:failed` or `:missing`).
    # @parameter message [String] The error message.
    def initialize(count_as, message)
      @count_as = count_as
      super message
    end
  end
end
