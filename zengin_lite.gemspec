require_relative 'lib/zengin_lite/version'

Gem::Specification.new do |spec|
  spec.name          = 'zengin_lite'
  spec.version       = ZenginLite::VERSION
  spec.authors       = ['Hiroyuki Kuromiya']
  spec.email         = ['contact@kromiii.info']

  spec.summary       = 'Lightweight Japanese bank and branch code database'
  spec.description   = 'A modern, fast, and memory-efficient implementation of Japanese bank code (Zengin Code) database with flexible query capabilities'
  spec.homepage      = 'https://github.com/kromiii/zengin-lite'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|source-data|scripts|\.github)/}) ||
        f.match(%r{^\.git})
    end
  end
  
  # Include the SQLite database
  spec.files << 'data/zengin.db' if File.exist?('data/zengin.db')
  
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_runtime_dependency 'sqlite3', '>= 1.4'
  
  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end