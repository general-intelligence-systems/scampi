# Changelog

All notable changes to this project are documented in this file.

## [0.1.8] - 2026-07-04

### Changed
- Vendored the `colorize` and `colorize-extended` sources into `lib/`, removing
  the external `colorize-extended` runtime dependency (and its transitive
  `colorize` dependency). Scampi now has no runtime gem dependencies.
