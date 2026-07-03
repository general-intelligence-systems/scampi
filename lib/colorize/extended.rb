# frozen_string_literal: true

require_relative 'extended/version'
require_relative 'extended/background_proxy'
require_relative 'extended/string_extensions'

class String
  include Colorize::Extended::StringExtensions
end
