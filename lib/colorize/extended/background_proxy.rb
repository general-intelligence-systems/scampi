# frozen_string_literal: true

module Colorize
  module Extended
    #
    # Proxy object returned by String#on that forwards
    # color method calls as background color applications.
    #
    # Example:
    #   "hello".red.on.blue  # equivalent to "hello".red.on_blue
    #
    class BackgroundProxy
      def initialize(string)
        @string = string
      end

      def method_missing(name, *args, &block)
        on_method = :"on_#{name}"
        if @string.respond_to?(on_method)
          @string.send(on_method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @string.respond_to?(:"on_#{name}", include_private) || super
      end
    end
  end
end
