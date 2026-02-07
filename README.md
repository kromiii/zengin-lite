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

### List all branches of a bank

```ruby
bank = ZenginLite.bank("0001")
branches = bank.branches(limit: 100)

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
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YOUR_USERNAME/zengin-lite.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).