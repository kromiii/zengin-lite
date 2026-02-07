#!/usr/bin/env ruby

require_relative '../lib/zengin_lite/version'

class Updater
  def run
    update_submodule
    build_database
    
    unless data_changed?
      puts "No data changes detected. Exiting."
      return
    end
    
    puts "Data changes detected. Starting release process..."
    
    configure_git
    new_version = bump_version
    
    puts "Bumped version to #{new_version}"
    
    commit_changes(new_version)
    
    puts "Releasing gem..."
    # Rely on Bundler's rake release, but we need to handle the git push and tag explicitly
    # if we want to customize the message or flow, but rake release does it all.
    # However, running rake release inside a script that is already running inside a job...
    # Let's try to use standard commands for better control in CI.
    
    # Actually, verify if we can just use `gem push`.
    # `rake release` is good because it safeguards.
    
    # We'll use system commands to run rake release.
    # But wait, rake release tries to push to git.
    # We verified permissions in workflow.
    
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
    # Check if data/zengin.db is modified
    !(`git status --porcelain data/zengin.db`.empty?)
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
    system("git add data/zengin.db lib/zengin_lite/version.rb")
    system("git commit -m 'Update data and bump version to #{version}'")
    # We do NOT push here because rake release will push.
  end
end

if __FILE__ == $0
  Updater.new.run
end
