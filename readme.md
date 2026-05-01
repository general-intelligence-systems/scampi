# Scampi

A small Ruby test framework forked from [Bacon](https://github.com/chneukirchen/bacon) with built-in TAP version 14 output. Tests can live alongside your implementation code using co-located test blocks that only run when the file is executed directly or via the scampi CLI.

Requires Ruby >= 3.3 and [ripgrep](https://github.com/BurntSushi/ripgrep) for test discovery.

## Usage

Please see the [project documentation](https://general-intelligence-systems.github.io/scampi/) for more details.

  - [Getting Started](https://general-intelligence-systems.github.io/scampi/guides/getting-started/index) - Install Scampi and write your first test.
  - [Co-Located Tests](https://general-intelligence-systems.github.io/scampi/guides/co-located-tests/index) - Place tests alongside implementation code with the test block.
  - [Assertions](https://general-intelligence-systems.github.io/scampi/guides/assertions/index) - The chainable .should DSL for equality, predicates, types, and custom matchers.
  - [Exceptions and Flow Control](https://general-intelligence-systems.github.io/scampi/guides/exceptions-and-flow/index) - Assert on raises, throws, and state changes.
  - [GitHub Actions](https://general-intelligence-systems.github.io/scampi/guides/github-actions/index) - Run Scampi in CI.

## See Also

  - [TAP (Test Anything Protocol)](https://testanything.org/)
  - [Bacon](https://github.com/chneukirchen/bacon) - The original project Scampi was forked from.

## License

Released under the MIT License. See [COPYING](https://github.com/general-intelligence-systems/scampi/blob/main/COPYING) for details.
