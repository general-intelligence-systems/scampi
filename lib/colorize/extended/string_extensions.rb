# frozen_string_literal: true

module Colorize
  module Extended
    #
    # Adds the #on method to String and ColorizedString,
    # enabling the chained syntax: "hello".red.on.blue
    #
    module StringExtensions
      def on
        Colorize::Extended::BackgroundProxy.new(self)
      end
    end
  end
end
