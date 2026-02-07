require 'sqlite3'
require 'json'
require 'fileutils'

module ZenginLite
  class DatabaseBuilder
    SOURCE_DIR = File.expand_path('../source-data/data', __dir__)
    OUTPUT_PATH = File.expand_path('../data/zengin.db', __dir__)
    
    def self.build!
      new.build!
    end
    
    def build!
      puts "🔨 Building SQLite database..."
      
      validate_source_data!
      
      FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
      File.delete(OUTPUT_PATH) if File.exist?(OUTPUT_PATH)
      
      db = SQLite3::Database.new(OUTPUT_PATH)
      
      create_schema(db)
      import_banks(db)
      import_branches(db)
      create_metadata(db)
      optimize_database(db)
      
      db.close
      
      display_summary
      
      puts "✅ Database built successfully!"
    end
    
    private
    
    def validate_source_data!
      unless Dir.exist?(SOURCE_DIR)
        raise "Source data not found: #{SOURCE_DIR}\nPlease run: git submodule update --init --recursive"
      end
      
      unless File.exist?("#{SOURCE_DIR}/banks.json")
        raise "banks.json not found in source-data"
      end
    end
    
    def create_schema(db)
      db.execute_batch <<-SQL
        CREATE TABLE banks (
          code TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          kana TEXT,
          hira TEXT,
          roma TEXT
        ) WITHOUT ROWID;
        
        CREATE INDEX idx_banks_name ON banks(name);
        CREATE INDEX idx_banks_kana ON banks(kana);
        
        CREATE TABLE branches (
          code TEXT NOT NULL,
          bank_code TEXT NOT NULL,
          name TEXT NOT NULL,
          kana TEXT,
          hira TEXT,
          roma TEXT,
          PRIMARY KEY (bank_code, code),
          FOREIGN KEY (bank_code) REFERENCES banks(code)
        ) WITHOUT ROWID;
        
        CREATE INDEX idx_branches_name ON branches(name);
        CREATE INDEX idx_branches_kana ON branches(kana);
        
        CREATE TABLE metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        ) WITHOUT ROWID;
      SQL
      
      puts "  ✓ Schema created"
    end
    
    def import_banks(db)
      banks_json = JSON.parse(File.read("#{SOURCE_DIR}/banks.json"))
      
      db.execute('BEGIN TRANSACTION')
      
      stmt = db.prepare(
        'INSERT INTO banks (code, name, kana, hira, roma) VALUES (?, ?, ?, ?, ?)'
      )
      
      banks_json.each do |code, bank|
        stmt.execute(code, bank['name'], bank['kana'], bank['hira'], bank['roma'])
      end
      
      stmt.close
      db.execute('COMMIT')
      
      @banks_count = banks_json.size
      puts "  ✓ Imported #{@banks_count} banks"
    end
    
    def import_branches(db)
      @branches_count = 0
      
      db.execute('BEGIN TRANSACTION')
      
      stmt = db.prepare(
        'INSERT INTO branches (code, bank_code, name, kana, hira, roma) VALUES (?, ?, ?, ?, ?, ?)'
      )
      
      Dir.glob("#{SOURCE_DIR}/branches/*.json").sort.each do |file|
        bank_code = File.basename(file, '.json')
        branches_json = JSON.parse(File.read(file))
        
        branches_json.each do |code, branch|
          stmt.execute(
            code, bank_code,
            branch['name'], branch['kana'], branch['hira'], branch['roma']
          )
        end
        
        @branches_count += branches_json.size
      end
      
      stmt.close
      db.execute('COMMIT')
      
      puts "  ✓ Imported #{@branches_count} branches"
    end
    
    def create_metadata(db)
      updated_at = File.read("#{SOURCE_DIR}/updated_at").strip
      md5 = File.read("#{SOURCE_DIR}/md5").strip
      
      db.execute('INSERT INTO metadata (key, value) VALUES (?, ?)', ['updated_at', updated_at])
      db.execute('INSERT INTO metadata (key, value) VALUES (?, ?)', ['md5', md5])
      
      puts "  ✓ Metadata added (updated_at: #{updated_at})"
    end
    
    def optimize_database(db)
      db.execute('VACUUM')
      db.execute('ANALYZE')
      puts "  ✓ Database optimized"
    end
    
    def display_summary
      file_size_kb = File.size(OUTPUT_PATH) / 1024
      file_size_mb = file_size_kb / 1024.0
      
      puts "\n📊 Summary:"
      puts "  Banks:     #{@banks_count}"
      puts "  Branches:  #{@branches_count}"
      puts "  File size: #{file_size_kb} KB (#{file_size_mb.round(2)} MB)"
      puts "  Location:  #{OUTPUT_PATH}"
    end
  end
end

ZenginLite::DatabaseBuilder.build! if __FILE__ == $PROGRAM_NAME