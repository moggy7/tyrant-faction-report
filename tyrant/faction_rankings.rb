# FactionRankings class to grab, organize, then export rankings data
class FactionRankings

  def self.data tyrant

    faction = tyrant.faction
    maximum_days = tyrant.config.report[:format].split(' ').collect{ |days| days.to_i }.max
    wars = tyrant.faction_wars(:days => maximum_days)

    today = Time.now.to_i
    wars.each do |war|

      slot = (today - war['start_time'].to_i)/86400

      tyrant.rankings(war).each do |rank|
        member = faction.find_member(rank['user_id'])
        member.fight(rank, slot) unless member.nil?
      end
    end


    sort = tyrant.config.report[:sort]
    method = FactionMember::CHARACTER_MAP[sort.pop][:method]
    members = faction.members.sort{ |one, two| one.send(method, sort.to_i) <=> two.send(method, sort.to_i) }
    members = members.reverse unless tyrant.config.report[:order] == 'asc'

    if tyrant.config.report[:aliases] == true
      self.generate_aliases(members)
    elsif tyrant.config.report[:aliases] && !tyrant.config.report[:aliases].empty?
      self.load_aliases(faction, tyrant.config)
    end

    members.collect do |player|
      player.to_s(tyrant.config.report[:format])
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

  def self.export filename, tyrant

    config = tyrant.config
    data = self.data tyrant

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

        data.each{ |line| puts line }
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