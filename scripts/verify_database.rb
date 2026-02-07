require 'sqlite3'
require_relative '../lib/zengin_lite'

module ZenginLite
  class DatabaseVerifier
    def self.verify!
      new.verify!
    end
    
    def verify!
      puts "🔍 Verifying database..."
      
      verify_file_exists
      verify_schema
      verify_data_integrity
      verify_api
      
      puts "\n✅ All verifications passed!"
    end
    
    private
    
    def verify_file_exists
      unless File.exist?(ZenginLite::DB_PATH)
        raise "Database file not found: #{ZenginLite::DB_PATH}"
      end
      puts "  ✓ Database file exists"
    end
    
    def verify_schema
      expected_tables = %w[banks branches metadata]
      actual_tables = Database.connection.execute(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
      ).flatten
      
      expected_tables.each do |table|
        unless actual_tables.include?(table)
          raise "Missing table: #{table}"
        end
      end
      
      puts "  ✓ Schema is valid"
    end
    
    def verify_data_integrity
      stats = ZenginLite.stats
      
      if stats[:banks_count] < 100
        raise "Unexpected low bank count: #{stats[:banks_count]}"
      end
      
      if stats[:branches_count] < 1000
        raise "Unexpected low branch count: #{stats[:branches_count]}"
      end
      
      puts "  ✓ Data integrity verified (#{stats[:banks_count]} banks, #{stats[:branches_count]} branches)"
    end
    
    def verify_api
      # Test bank lookup
      bank = ZenginLite.bank('0001')
      raise "Bank lookup failed" unless bank
      raise "Bank name missing" if bank.name.nil? || bank.name.empty?
      
      # Test bank search
      results = ZenginLite.search_banks(name: '農協', limit: 5)
      raise "Bank search failed" if results.empty?
      
      # Test branch lookup
      branch = bank.branch('001')
      raise "Branch lookup failed" unless branch
      
      # Test branch access to bank
      raise "Branch->Bank association failed" unless branch.bank
      
      puts "  ✓ API functionality verified"
    end
  end
end

ZenginLite::DatabaseVerifier.verify! if __FILE__ == $PROGRAM_NAME