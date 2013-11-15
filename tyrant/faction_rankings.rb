# FactionRankings class to grab, organize, then export rankings data
class FactionRankings

  def self.data config
    tyrant = Tyrant.new(config.settings)
    tyrant.connect

    faction = tyrant.faction #get all faction members
    maximum_days = config.report[:format].split(' ').collect{ |days| days.to_i }.max
    wars = tyrant.faction_wars(:days => maximum_days) #get array of all matching wars

    today = Time.now.to_i
    wars.each do |war|

      slot = (today - war['start_time'].to_i)/86400 #slot war was "slot" days ago

      tyrant.rankings(war).each do |rank| #reads info for this war from tyrant, then analyze this info
        member = faction.find_member(rank['user_id']) #user id from war
        member.fight(rank, slot) unless member.nil?
      end
    end


    sort = config.report[:sort]
    method = FactionMember::CHARACTER_MAP[sort.pop][:method]
    members = faction.members.sort{ |one, two| one.send(method, sort.to_i) <=> two.send(method, sort.to_i) } #sort member list, normally by net damage 7d
    members = members.reverse unless config.report[:order] == 'asc'

    if config.report[:aliases] == true #allows to replace member names by aliases
      self.generate_aliases(members)
    elsif config.report[:aliases] && !config.report[:aliases].empty?
      self.load_aliases(faction, config)
    end

    members.collect do |player| #returns new array with statistic info for each player
      player.to_s(config.report[:format])
    end
  end

  def self.generate_aliases members
    file = File.open('config/aliases.json', 'w')
    file.puts '{'

    members.each do |member|
      alias_string = "  \"#{member.id}\":"
      alias_string << ' ' * 20 - alias_string.length
      alias_string << "\"#{member.name || 'UNKNOWN'}\""
      alias_string << "," unless members.last == member
      file.puts alias_string
    end
    file.puts '}'
    file.close
  end

  def self.load_aliases faction, config
    file = File.open(config.report[:aliases], 'r')
    aliases = JSON.parse(file.read)
    aliases.each do |key, aliased|
      faction.find_member(key).name = aliased
    end
  end

  def self.header_string report
    description = FactionMember::CHARACTER_MAP[report.pop][:description]
    "#{description}#{ " #{report}d" unless report.empty?}"
  end

  def self.export filename #main starting point of this program

    config = Configuration.load #load configuration
    data = self.data config #get stastic data for each member

    if config.spreadsheet[:key].empty?
      header = config.report[:format].split(' ').collect do |report|
        "\"#{header_string report}\""
      end.join(',')


      path = filename || config.report[:output]
      if path && !path.empty?
        puts "Saving to file.  Path: #{path}"
        file = File.open(path,'w')
        file.puts header
        data.each{ |line| file.puts line }
        file.close
      else
        puts "No detected filesave path. If you want to save to a file, please update config/spreadsheet.yaml or config/report.yml.\n\n"
        puts header
        data.each{ |line| puts line } # output to command line
      end
    else
      session = GoogleDrive.login(config.spreadsheet[:username], config.spreadsheet[:password])
      ws = session.spreadsheet_by_key(config.spreadsheet[:key]).worksheets[0]
      config.report[:format].split(' ').each_with_index do |report, index|
        ws[1, index + 1] = header_string report
      end
      data.each_with_index do |line, row|
        line.split(',').each_with_index do |item, col|
          ws[row + 2, col + 1] = item.gsub('"', '')
        end
      end
      ws.save()
    end
  end
end