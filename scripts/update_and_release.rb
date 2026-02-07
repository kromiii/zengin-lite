#!/usr/bin/env ruby

require_relative '../lib/zengin_lite/version'

class Updater
  def run
    configure_git

    update_submodule
    build_database
    
    if data_changed?
      puts "Data changes detected. Starting release process..."
      new_version = bump_version
      puts "Bumped version to #{new_version}"
      commit_changes(new_version)
      release_gem
    elsif !version_tagged?
      puts "Version #{current_version} is not tagged. Releasing..."
      release_gem
    else
      puts "No data changes detected and version #{current_version} is already tagged. Exiting."
    end
  end

  private

  def current_version
    ZenginLite::VERSION
  end

  def version_tagged?
    system("git rev-parse v#{current_version} >/dev/null 2>&1")
  end

  def release_gem
    puts "Releasing gem..."
    system("bundle exec rake release") or raise "Release failed"
  end

  private

  def update_submodule
    system("git submodule update --remote") or raise "Submodule update failed"
  end

  def build_database
    system("ruby scripts/build_database.rb") or raise "Database build failed"
  end

  def data_changed?
    # Check if source-data submodule has changed
    !(`git status --porcelain source-data`.empty?)
  end

  def configure_git
    system('git config user.name "github-actions[bot]"')
    system('git config user.email "41898282+github-actions[bot]@users.noreply.github.com"')
  end

  def bump_version
    current = ZenginLite::VERSION
    major, minor, patch = current.split('.').map(&:to_i)
    new_version = "#{major}.#{minor}.#{patch + 1}"
    
    version_file = File.expand_path('../lib/zengin_lite/version.rb', __dir__)
    content = File.read(version_file)
    new_content = content.gsub(/VERSION = "#{current}"/, "VERSION = \"#{new_version}\"")
    File.write(version_file, new_content)
    
    new_version
  end

  def commit_changes(version)
    system("git add source-data lib/zengin_lite/version.rb")
    system("git commit -m 'Update data and bump version to #{version}'")
    # We do NOT push here because rake release will push.
  end
end

if __FILE__ == $0
  Updater.new.run
end
