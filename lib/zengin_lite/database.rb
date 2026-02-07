require 'sqlite3'

module ZenginLite
  # @api private
  class Database
    class << self
      def connection
        @connection ||= begin
          unless File.exist?(ZenginLite::DB_PATH)
            raise "Database file not found: #{ZenginLite::DB_PATH}"
          end
          
          db = SQLite3::Database.new(ZenginLite::DB_PATH.to_s, readonly: true)
          db.results_as_hash = false
          db
        end
      end
      
      def close
        @connection&.close
        @connection = nil
      end
      
      # Query methods
      def find_bank(code:)
        connection.get_first_row(
          'SELECT code, name, kana, hira, roma FROM banks WHERE code = ?',
          [code]
        )
      end
      
      def search_banks(name: nil, kana: nil, limit: 10)
        sql = 'SELECT code, name, kana, hira, roma FROM banks WHERE 1=1'
        params = []
        
        if name
          sql += ' AND name LIKE ?'
          params << "%#{name}%"
        end
        
        if kana
          sql += ' AND kana LIKE ?'
          params << "%#{kana}%"
        end
        
        sql += ' LIMIT ?'
        params << limit
        
        connection.execute(sql, params)
      end
      
      def each_bank(&block)
        connection.execute('SELECT code, name, kana, hira, roma FROM banks') do |row|
          block.call(row)
        end
      end
      
      def find_branch(bank_code:, branch_code:)
        connection.get_first_row(
          'SELECT code, bank_code, name, kana, hira, roma FROM branches WHERE bank_code = ? AND code = ?',
          [bank_code, branch_code]
        )
      end
      
      def find_branches(bank_code:, limit: 100)
        limit ||= -1
        connection.execute(
          'SELECT code, bank_code, name, kana, hira, roma FROM branches WHERE bank_code = ? LIMIT ?',
          [bank_code, limit]
        )
      end
      
      def metadata(key)
        row = connection.get_first_row(
          'SELECT value FROM metadata WHERE key = ?',
          [key]
        )
        row&.first
      end
      
      def stats
        {
          banks_count: connection.get_first_value('SELECT COUNT(*) FROM banks'),
          branches_count: connection.get_first_value('SELECT COUNT(*) FROM branches'),
          updated_at: metadata('updated_at'),
          md5: metadata('md5')
        }
      end
    end
  end  
end