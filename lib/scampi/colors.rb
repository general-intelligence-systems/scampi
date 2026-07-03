# frozen_string_literal: true

# Minimal ANSI coloring — trimmed from the colorize gem to only the two
# colors Scampi actually uses (green for "ok", red for "not ok"). Output is
# byte-for-byte identical to colorize's String#green / String#red.
module Scampi
  module Colors
    # foreground code, default background (49), default mode (0)
    def green = "\e[0;32;49m#{self}\e[0m"
    def red   = "\e[0;31;49m#{self}\e[0m"
  end
end

class String
  include Scampi::Colors
end
