# Tyrant object for interfacing with Tyrant's API

load 'tyrant/configuration.rb'
load 'extensions/string_extensions.rb'
load 'extensions/net_http_cache.rb'

class Tyrant

  TIME_HASH = 'fgjk380vf34078oi37890ioj43'

  def initialize(opts = {})
    @config = Configuration.load
    @flash_code = @config.settings[:flashcode]
    @faction_id = @config.settings[:faction_id]
    @user_id = @config.settings[:user_id]
    @game_auth_token = @config.settings[:game_auth_token]
    @version = @config.settings[:version]

    @facebook = @config.settings[:facebook]
    @path = @facebook ? 'fb.tyrantonline.com' : 'kg.tyrantonline.com'

    @client_code = opts[:client_code] | @config.settings[:client_code]

    @headers = {
      "Host" => "#{@path}",
      "User-Agent" => @config.settings[:user_agent],
      "Accept" => "*/*",
      "Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
      "Accept-Encoding" => "gzip,deflate,sdch",
      "Accept-Language" => "en-US,en;q=0.8",
      "Connection" => "keep-alive",
      "Referer" => "http://#{@path}/Main.swf?#{@version}",
      "Content-Type" => "application/x-www-form-urlencoded"
    }

    self.connect if(@client_code == nil or @faction_id.to_i == 0)
	@config
  end

  attr_reader :config

  def connection
    @connection ||= Net::HTTP.new(@path, 80)
  end

  def fetch_collection message, key, params = {}
    time = Time.now.to_i/(60*15)
    ccache = Digest::MD5.hexdigest(time.to_s + @user_id.to_s)
    hash = Digest::MD5.hexdigest(message + time.to_s + TIME_HASH)

    path = "/api.php?user_id=#{@user_id}&message=#{message}"
    data = "flashcode=#{@flash_code}&time=#{time}&version=#{@version}&hash=#{hash}&ccache=&client_code=#{@client_code}"
    data << "&game_auth_token=#{@game_auth_token}&rc=2" unless @facebook
    params.each{|key, value| data << "&#{key}=#{value}"}

    response = connection.cached_request(path, data, @headers, key)
    parsed = JSON.parse(response)
    if(parsed['duplicate_client'] == 1)
      self.connect
      File.delete("cache/#{key}.cache")
      parsed = fetch_collection message, key, params
    end
    parsed
  end

  def connect
    time = 0
    message = "init"
    ccache = Digest::MD5.hexdigest(time.to_s + @user_id.to_s)
    hash = Digest::MD5.hexdigest(message + time.to_s + TIME_HASH)

    path = "/api.php?user_id=#{@user_id}&message=#{message}"
    data = "?&flashcode=#{@flash_code}&time=#{time}&version=""&hash=#{hash}&ccache=#{ccache}"
    data << "&game_auth_token=#{@game_auth_token}&rc=2" unless @facebook
    response = connection.post2(path, data, @headers).body.inflate    # We don't want to cache this request
    json = JSON.parse(response)
    @client_code = json["client_code"]
    @faction_id = json["faction_id"].to_i
	@version = json["version"]
	@config.settings[:client_code] = @client_code
	@config.settings[:faction_id] = @faction_id
	@config.settings[:version] = @version
	@config.save
	if json["result"] != nil && json["result"] == false
      puts "Warning: Connect Problem? #{json.to_s}"
      raise "I give up and fail. Please clear /cache folder before you try again"
    end
    return json
  end

  def faction
    json = self.fetch_collection 'getFactionMembers', "members.#{@faction_id}.#{Date.today}", { :faction_id => @faction_id }
    faction = Faction.new @faction_id

	if json['members'] == nil
      puts "Error. Could not find ['members'] #{json.to_s}"
      return
    end
	
    json['members'].each do |key, member|
      faction.add_member(
        :id => member['user_id'],
        :name => member['name'],
        :level => member['level'],
        :last_activity => member['last_active_day'],
        :loyalty => member['loyalty'],
        :token_claim => member['conquest_claimed'],
        :rank => member['permission_level']
      )
    end
    faction
  end

  def faction_wars options
    json = self.fetch_collection 'getOldFactionWars', "wars.#{Date.today}"

    wars = json['wars']
    wars = wars.select{ |war| (Time.now.to_i - war['start_time'].to_i)/86400 <= options[:days] } if options[:days]
    wars = wars.select{ |war| war['name'] == options[:faction] } if options[:faction]
    wars
  end

  def rankings war
    begin
      json = self.fetch_collection 'getFactionWarRankings', "war.#{war['faction_war_id']}", { :faction_war_id => war['faction_war_id'] }
      puts "Evaluating War #{war['faction_war_id']}"
      json['rankings'][@faction_id.to_s]
    rescue Zlib::GzipFile::Error, Zlib::DataError
      $stderr.puts "Compression error. Attempting to continue."
      []
    end
  end
end