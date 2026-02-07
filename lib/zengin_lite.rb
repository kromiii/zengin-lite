require 'sqlite3'
require_relative 'zengin_lite/version'
require_relative 'zengin_lite/database'
require_relative 'zengin_lite/bank'
require_relative 'zengin_lite/branch'

module ZenginLite
  class Error < StandardError; end
  
  class << self
    # Find bank by code
    def bank(code)
      row = Database.find_bank(code: code)
      Bank.from_row(row)
    end
    
    # Search banks by name or kana
    def search_banks(name: nil, kana: nil, limit: 10)
      Database.search_banks(name: name, kana: kana, limit: limit).map do |row|
        Bank.from_row(row)
      end
    end
    
    # Iterate through all banks (memory efficient)
    def each_bank(&block)
      Database.each_bank do |row|
        block.call(Bank.from_row(row))
      end
    end
    
    # Find branch by bank code and branch code
    def branch(bank_code:, branch_code:)
      row = Database.find_branch(bank_code: bank_code, branch_code: branch_code)
      Branch.from_row(row)
    end
    
    # Get database statistics
    def stats
      Database.stats
    end
  end
end