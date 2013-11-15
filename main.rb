#!/usr/bin/env ruby

require 'yaml'
require 'digest/md5'
require 'net/http'
require 'uri'
require 'zlib'
require 'json'
require 'date'

# Configuration class to load in custom user settings and values
load 'tyrant/tyrant.rb'
load 'extensions/string_extensions.rb'
load 'extensions/net_http_cache.rb'
load 'tyrant/faction.rb'
load 'tyrant/faction_rankings.rb'

unless !File.exists?('config/spreadsheet.yml') || Configuration.load.spreadsheet[:key].empty?
  require 'rubygems'
  require 'google_drive'
end

FactionRankings.export(ARGV[0])