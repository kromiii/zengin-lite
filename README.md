# ZenginLite

[![Gem Version](https://badge.fury.io/rb/zengin_lite.svg)](https://badge.fury.io/rb/zengin_lite)
[![update](https://github.com/YOUR_USERNAME/zengin-lite/actions/workflows/update.yml/badge.svg)](https://github.com/YOUR_USERNAME/zengin-lite/actions/workflows/update.yml)

A lightweight, modern Ruby implementation of Japanese bank and branch code database.

Rebuilt from scratch with focus on:
- ⚡️ Fast startup time (5-10ms vs 200-500ms)
- 💾 Low memory footprint (1MB vs 10-15MB)
- 🔍 Flexible query capabilities
- 📦 Compact size (~800KB)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zengin_lite'
```

Or install it yourself as:

```bash
$ gem install zengin_lite
```

## Usage

```ruby
require 'zengin_lite'

# Find bank and branch
bank = ZenginLite.bank("0001") # => #<ZenginLite::Bank code="0001" name="みずほ銀行" ...>
branch = bank.branch("001")    # => #<ZenginLite::Branch code="001" name="東京営業部" ...>

# Search banks
banks = ZenginLite.search_banks(name: "三井")

# Check existence (returns nil if not found)
ZenginLite.bank("9999") # => nil
```

For more detailed API documentation, please refer to the YARD documentation.

```bash
# Generate and view documentation locally
$ bundle exec yard doc
$ open doc/index.html
```

Online documentation is available at [rubydoc.info](https://rubydoc.info/gems/zengin_lite).

## Data Source

This gem uses data from [zengin-code/source-data](https://github.com/zengin-code/source-data), which is automatically updated daily.

## Comparison with zengin_code

| Feature | zengin_code | zengin_lite |
|---------|-------------|-------------|
| Startup time | 200-500ms | 5-10ms |
| Memory usage | 10-15MB | <1MB |
| Gem size | 788KB | ~800KB |
| Search capability | Basic | Flexible SQL queries |
| Data loading | Eager (all at once) | Lazy (on demand) |

## Development

```bash
# Clone with submodule
$ git clone --recursive https://github.com/kromiii/zengin-lite.git
$ cd zengin-lite
$ bundle install

# Update source data and build database
$ git submodule update --remote
$ bundle exec rake db:build

# Run tests
$ bundle exec rake test

# Verify database integrity
$ bundle exec rake db:verify

# Build and install locally (database will be built automatically)
$ bundle exec rake install

# Generate documentation
$ bundle exec yard doc
$ open doc/index.html
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
