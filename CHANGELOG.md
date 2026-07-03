# Changelog

All notable changes to this project are documented in this file.

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
