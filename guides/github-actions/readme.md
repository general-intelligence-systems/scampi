# GitHub Actions

This guide shows how to run Scampi tests in CI with GitHub Actions.

## Workflow

Create `.github/workflows/test.yml` in your repository:

```yaml
name: Test

on: [push, pull_request]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - run: sudo apt-get install -y ripgrep

      - run: bundle exec scampi
```

The workflow installs ripgrep (required for test discovery) and runs all tests via `bundle exec scampi`.
