
# FactionMember object to track rankings data and associated calculations for a single player
class FactionMember

  CHARACTER_MAP = {
    'a' => {:description => 'Battles Initiated',  :method => :battles,          :format => '%05d'},
    'd' => {:description => 'Net Damage',         :method => :net_damage,       :format => '%07d'},
    'l' => {:description => 'Loyalty Gain',       :method => :wins,             :format => '%05d'},
    'i' => {:description => 'User ID',            :method => :id,               :format => '%d'},
    'n' => {:description => 'Name',               :method => :name,             :format => '%s'},
    'p' => {:description => 'Win %',              :method => :win_percentage,   :format => '%06.2f%'},
    'q' => {:description => 'Last Login',         :method => :last_login,       :format => '%03d days ago'},
    'r' => {:description => 'Total Losses',       :method => :losses,           :format => '%05d'},
    's' => {:description => 'Approx. Surge %',    :method => :surge_percentage, :format => '%06.2f%'},
    'u' => {:description => 'Total Loyalty',      :method => :loyalty,          :format => '%05d'},
    'v' => {:description => 'Level',              :method => :level,            :format => '%03d'},
    'w' => {:description => 'Total Wins',         :method => :wins,             :format => '%05d'}
  }

  def initialize params
    @id = params[:id].to_i
    @name = params[:name]
    @level = params[:level].to_i
    @last_activity = params[:last_activity].to_i
    @loyalty = params[:loyalty].to_i

    @wars = []
    @stats = []
    @totals = []
  end

  def fight stats, days_ago
    @wars[days_ago] ||= []
    @wars[days_ago].push stats
  end

  ## calculation utilities (with memoization)
  def sum attribute, days_ago
    @stats[days_ago] ||= {}
    @stats[days_ago][attribute] ||= @wars[days_ago] ? @wars[days_ago].collect{ |war| war[attribute].to_i }.inject(0, :+) : 0
  end

  def total attribute, days_ago
    @totals[days_ago] ||= {}
    @totals[days_ago][attribute] ||= (0..days_ago).collect{ |day| self.sum(attribute, day).to_i }.inject(0, :+)
  end

  ## calculations
  def wins days_ago
    self.total 'wins', days_ago
  end

  def losses days_ago
    self.total 'losses', days_ago
  end

  def battles days_ago
    self.total 'battles_fought', days_ago
  end

  def damage_dealt days_ago
    self.total 'points', days_ago
  end

  def damage_taken days_ago
    self.total 'points_against', days_ago
  end

  def net_damage days_ago
    self.damage_dealt(days_ago) - self.damage_taken(days_ago)
  end

  def surges days_ago
    # use a heuristic to determine the rough number of battles that are surges
    @totals[days_ago] ||= {}
    @totals[days_ago]['surges'] = [(self.damage_dealt(days_ago)/20 - self.wins(days_ago)).abs, self.battles(days_ago)].min
  end

  def surge_percentage days_ago
    win_count = self.wins(days_ago)
    win_count > 0 ? ([self.surges(days_ago).to_f/win_count.to_f*100, 100.0].min) : 0
  end

  def win_percentage days_ago
    win_count = self.wins(days_ago)
    loss_count = self.losses(days_ago)
    total_battles = win_count + loss_count
    total_battles > 0 ? win_count.to_f/total_battles.to_f * 100.0 : 0
  end

  def id _
    @id
  end

  def last_login _
    Time.now.to_i/86400 - @last_activity
  end

  def level _
    @level
  end

  def loyalty _
    @loyalty
  end

  def name _
    @name
  end

  def name= value
    @name = value
  end

  def to_s format = REPORT[:format]

    format.split(' ').collect do |report|

      mapping = CHARACTER_MAP[report.pop]
      value = mapping[:format] % self.send(mapping[:method], report.to_i)
      "\"#{value}\""
    end.join(',')
  end
end
