require_relative 'lib/scampi/version'

Gem::Specification.new do |s|
  s.name            = "scampi"
  s.version         = Scampi::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "a small RSpec clone with built-in TAP support"
  s.license         = "MIT"

  s.description = <<-EOF
Scampi is a small RSpec clone weighing less than 350 LoC but
nevertheless providing all essential features. Includes a
TAP (Test Anything Protocol) harness and assertion library.

http://github.com/general-intelligence-systems/scampi
  EOF

  s.files           = `git ls-files`.split("\n") - [".gitignore"] + %w(RDOX ChangeLog)
  s.bindir          = 'exe'
  s.executables     = ['scampi']
  s.require_path    = 'lib'
  s.extra_rdoc_files = ['README.rdoc', 'RDOX']
  s.test_files      = []

  s.add_dependency 'colorize-extended'

  s.author          = 'Nathan K'
  s.email           = 'nathankidd@hey.com'
  s.homepage        = 'http://github.com/general-intelligence-systems/scampi'
end
