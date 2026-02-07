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

### Find bank by code

```ruby
require 'zengin_lite'

bank = ZenginLite.bank("0001")
# => #<ZenginLite::Bank code="0001", name="みずほ銀行", kana="ミズホ", hira="みずほ", roma="mizuho">

puts bank.name  # => "みずほ銀行"
puts bank.kana  # => "ミズホ"
puts bank.roma  # => "mizuho"
```

### Search banks by name

```ruby
banks = ZenginLite.search_banks(name: "三井")
# => [#<ZenginLite::Bank ...>, ...]

banks.each do |bank|
  puts "#{bank.code}: #{bank.name}"
end
```

### Find branch

```ruby
# Get branch through bank
bank = ZenginLite.bank("0001")
branch = bank.branch("001")
# => #<ZenginLite::Branch code="001", name="東京営業部", ...>

# Or directly
branch = ZenginLite.branch(bank_code: "0001", branch_code: "001")
puts branch.name  # => "東京営業部"
puts branch.bank.name  # => "みずほ銀行"
```

### Check existence

If a bank or branch does not exist, `nil` is returned.

```ruby
# Bank not found
bank = ZenginLite.bank("9999")
if bank.nil?
  puts "Bank not found"
end

# Branch not found
branch = ZenginLite.branch(bank_code: "0001", branch_code: "999")
if branch.nil?
  puts "Branch not found"
end
```

### List all branches of a bank

```ruby
```ruby
bank = ZenginLite.bank("0001")
branches = bank.branches

branches.each do |branch|
  puts "#{branch.code}: #{branch.name}"
end
```

### Iterate through all banks (memory efficient)

```ruby
ZenginLite.each_bank do |bank|
  puts "#{bank.code}: #{bank.name}"
end
```

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

### Compatibility with zengin-rb

`zengin-lite` provides compatibility methods for `zengin-rb` users:

- `ZenginLite::Bank.all`: Returns a Hash of all banks (same as `ZenginCode::Bank.all`).
- `ZenginLite::Bank['0001']`: Alias for `ZenginLite.bank('0001')`.

Note: `ZenginLite::Bank#branches` returns an Array of all branches by default (limit: nil), effectively similar to `zengin-rb`.

## Development

```bash
# Clone with submodule
$ git clone --recursive https://github.com/YOUR_USERNAME/zengin-lite.git
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YOUR_USERNAME/zengin-lite.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Release Flow

This gem uses [GitHub Actions](https://github.com/kromiii/zengin-lite/actions) to automate the release process.

### Automatic Updates
The workflow runs automatically **every day at 9:00 JST** to check for updates in the source data ([zengin-code/source-data](https://github.com/zengin-code/source-data)).

1. **Check for Updates**: It fetches the latest data from `source-data` and rebuilds the SQLite database.
2. **Release**: 
   - If changes are detected in `data/zengin.db`, the patch version is automatically incremented (e.g., `0.1.0` -> `0.1.1`).
   - A new version is released to RubyGems.

### Manual Releases
You can also trigger a release by pushing to the `main` branch.

1. **Update Code**: Make changes to the code (e.g., `lib/`) and push to `main`.
2. **Release**:
   - The workflow checks if the current version (in `version.rb`) is already tagged.
   - If **NOT tagged**, it will be released as a new version.
   - If **already tagged**, no action is taken.

### Prerequisites for Release
To enable automatic releases, the following secret must be set in the repository settings:

- `RUBYGEMS_API_KEY`: An API key from RubyGems.org with push permissions.