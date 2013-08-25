require 'yaml'

class Configuration
  SETTINGS = {
    :flashcode => '',
    :faction_id => '',
    :user_id => '',
    :game_auth_token => '',
    :facebook => false,
    :client_id => nil,
	:user_agent => "Ruby Net Point Script 1.7.1"
  }

  SPREADSHEET = {
    :key => '',
    :username => '',
    :password => ''
  }

  REPORT = {
    :format => 'n v 7d 7w 7s 7a',
    :sort => '7d',
    :order => 'desc',
    :aliases => false,
    :output => ''
  }

  VALUES = [:settings, :spreadsheet, :report]

  def save
    VALUES.each do |key|
      file_path = "config/#{key}.yml"
      if File.exists?(file_path)
        self.send(:"#{key}=", YAML::load(File.open(file_path)))
      else
        install
        redo
      end
    end
    self
  end

  def self.install
    Dir::mkdir('config') unless FileTest::directory?('config')
    VALUES.each do |key|
      file_path = "config/#{key}.yml"
      defaults = const_get(key.to_s.upcase.to_sym)
      puts File.exists?(file_path) ? "Updating: #{file_path}" : "Installing: #{file_path}"
      current = File.exists?(file_path) ? YAML::load(File.open(file_path, 'r')) : {}
      settings = File.open(file_path, 'w')
      settings.write(YAML::dump(defaults.merge(current)))
      settings.close
    end
  end

  def self.load
    config = Configuration.new
    VALUES.each do |key|
      file_path = "config/#{key}.yml"
      if File.exists?(file_path)
        config.send(:"#{key}=", YAML::load(File.open(file_path)))
      else
        install
        redo
      end
    end
    [:flashcode, :user_id, :game_auth_token].each do |key|
		if config.settings[key] == nil || config.settings[key] == ''
			raise "Missing configuration setting #{key}. Please add your user values to config/settings.yml and try again."
		end
	end

    config
  end

  def initialize
    @settings = SETTINGS
    @spreadsheet = SPREADSHEET
    @report = REPORT
  end


  VALUES.each do |key|
    define_method key do
      instance_variable_get("@#{key}")
    end

    define_method :"#{key}=" do |values|
      instance_variable_set("@#{key}", self.send(key).merge(values))
    end
  end
end
