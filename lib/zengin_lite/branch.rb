module ZenginLite
  class Branch
    attr_reader :code, :bank_code, :name, :kana, :hira, :roma
    
    def bank
      ZenginLite.bank(bank_code)
    end

    def initialize(code:, bank_code:, name:, kana:, hira:, roma:)
      @code = code
      @bank_code = bank_code
      @name = name
      @kana = kana
      @hira = hira
      @roma = roma
    end
    
    def to_h
      {
        code: code,
        bank_code: bank_code,
        name: name,
        kana: kana,
        hira: hira,
        roma: roma
      }
    end

    def inspect
      "#<#{self.class.name} code=#{code.inspect}, bank_code=#{bank_code.inspect}, name=#{name.inspect}, kana=#{kana.inspect}>"
    end
    
    # @api private
    def self.from_row(row)
      return nil unless row
      
      new(
        code: row[0],
        bank_code: row[1],
        name: row[2],
        kana: row[3],
        hira: row[4],
        roma: row[5]
      )
    end
  end
end
