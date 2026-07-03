# Changelog

All notable changes to this project are documented in this file.

## [1.0.0] - 2026-07-04

### Changed
- **Breaking:** co-located tests now live in an `__END__` section instead of a
  `test do ... end` block. The section after `__END__` is never parsed in
  production and is evaluated as spec code by the `scampi` runner (backtraces
  keep the original file/line numbers). `scampi` with no arguments now
  auto-discovers `.rb` files whose `__END__` section contains specs.

### Removed
- The `Kernel#test` method (`lib/scampi/kernel_ext.rb`). Running a source file
  directly (`ruby greet.rb`) no longer executes its tests; use `scampi` instead.

## [0.1.9] - 2026-07-04

### Changed
- Replaced the vendored `colorize` sources with a minimal `lib/scampi/colors.rb`
  providing only the `String#green` and `String#red` methods Scampi uses. Output
  is byte-for-byte identical; ~200 lines of vendored code reduced to ~15.

## [0.1.8] - 2026-07-04

### Changed
- Vendored the `colorize` and `colorize-extended` sources into `lib/`, removing
  the external `colorize-extended` runtime dependency (and its transitive
  `colorize` dependency). Scampi now has no runtime gem dependencies.
