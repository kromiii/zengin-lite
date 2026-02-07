$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'zengin_lite'
require 'minitest/autorun'

class Minitest::Test
  def setup
    unless File.exist?(ZenginLite::DB_PATH)
      skip "Database not found. Run: bundle exec rake db:build"
    end
  end
end