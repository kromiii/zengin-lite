module ZenginLite
  class Bank
    class << self
      def all
        banks = {}
        ZenginLite.each_bank do |bank|
          banks[bank.code] = bank
        end
        banks
      end

      def [](code)
        ZenginLite.bank(code)
      end
    end

    attr_reader :code, :name, :kana, :hira, :roma
    
    def initialize(code:, name:, kana:, hira:, roma:)
      @code = code
      @name = name
      @kana = kana
      @hira = hira
      @roma = roma
    end
    
    def branch(branch_code)
      row = Database.find_branch(bank_code: code, branch_code: branch_code)
      Branch.from_row(row) if row
    end
    
    def branches(limit: nil)
      Database.find_branches(bank_code: code, limit: limit).each_with_object({}) do |row, hash|
        branch = Branch.from_row(row)
        hash[branch.code] = branch
      end
    end
    
    def to_h
      {
        code: code,
        name: name,
        kana: kana,
        hira: hira,
        roma: roma
      }
    end
    
    def inspect
      "#<#{self.class.name} code=#{code.inspect}, name=#{name.inspect}, kana=#{kana.inspect}>"
    end
    
    def self.from_row(row)
      return nil unless row
      
      new(
        code: row[0],
        name: row[1],
        kana: row[2],
        hira: row[3],
        roma: row[4]
      )
    end
  end
end