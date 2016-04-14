require "rubygems"
require "rubygems/package"

require "active_support"
require "active_support/core_ext"
require "commander"

begin
  require "pry"
rescue LoadError ; end

module Metacrunch
  require_relative "metacrunch/version"
  require_relative "metacrunch/cli"
  require_relative "metacrunch/job"

  def self.load_plugins
    Gem.find_latest_files("metacrunch_plugin.rb").each do |path|
      load(path)
    end
  end

end
