
# FactionMember object to track rankings data and associated calculations for a single player
class FactionMember

  CHARACTER_MAP = {
    'a' => {:description => 'Battles Initiated',  :method => :battles,          :format => '%05d'},
    'b' => {:description => 'Points Won',         :method => :damage_dealt,     :format => '%05d'},
    'c' => {:description => 'Points Against',     :method => :damage_taken,     :format => '%05d'},
    'd' => {:description => 'Net Damage',         :method => :net_damage,       :format => '%07d'},
    'e' => {:description => 'Total Wins Atk',     :method => :wins_attack,      :format => '%05d'},
    'f' => {:description => 'Total Losses Atk',   :method => :losses_attack,    :format => '%05d'},
    'g' => {:description => 'Total Wins Def',     :method => :wins_defense,     :format => '%05d'},
    'h' => {:description => 'Total Losses Def',   :method => :losses_defense,   :format => '%05d'},
    'i' => {:description => 'User ID',            :method => :id,               :format => '%d'},
    'l' => {:description => 'Loyalty Gain',       :method => :wins,             :format => '%05d'},
    'm' => {:description => 'Win % Def',          :method => :win_percentage_d, :format => '%06.2f%'},
    'n' => {:description => 'Name',               :method => :name,             :format => '%s'},
    'o' => {:description => 'Rank',               :method => :rank,             :format => '%s'},
    'p' => {:description => 'Win % Atk',          :method => :win_percentage,   :format => '%06.2f%'},
    'q' => {:description => 'Last Login',         :method => :last_login,       :format => '%03d days ago'},
    'r' => {:description => 'Total Losses',       :method => :losses,           :format => '%05d'},
    's' => {:description => 'Est. Surge %',       :method => :surge_percentage, :format => '%06.2f%'},
    't' => {:description => 'Last Claim',         :method => :token_claim,      :format => '%04.1f days ago'},
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
    @token_claim = params[:token_claim].to_i
    @rank = params[:rank].to_i

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
  def wins days_ago #'wins'
    self.wins_attack(days_ago) + self.wins_defense(days_ago)
  end
 
  def losses days_ago #'losses'
    self.losses_attack(days_ago) + self.losses_defense(days_ago)
  end
 
  def wins_attack days_ago #'wins_attack'
    self.total 'wins', days_ago
  end
 
  def losses_attack days_ago #'losses_attack'
    self.total 'losses', days_ago
  end
 
  def wins_defense days_ago #'wins_defense'
    self.total 'defense_wins', days_ago
  end
 
  def losses_defense days_ago #'losses_defense'
    self.total 'defense_losses', days_ago
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
    # example 400 damage dealt in 10 'wins' battles => 10 Surges
    # however normalize this to total battles fought because otherwise
    # example 450 damage dealt in 10 'wins' battles and also total number of battles of '10' => 15 Surges while only 10 is max
    # therefore min of battles is used
    # however as battles is used to normalize the result, but surge_percentage is expressed in terms of surges/win this value
    # could become more then 100%
    # example 450 damage dealt in 10 wins in 11 battles => 11 surges => 11 surges / 10 wins => 110%
    @totals[days_ago] ||= {}
    @totals[days_ago]['surges'] = [(self.damage_dealt(days_ago)/20 - self.wins_attack(days_ago)).abs, self.battles(days_ago)].min
  end

  def surge_percentage days_ago
    #could be more then 100% see comment @surges
    win_count = self.wins_attack(days_ago)
    win_count > 0 ? ([self.surges(days_ago).to_f/win_count.to_f*100, 100.0].min) : 0
  end

  def win_percentage days_ago
    # really refers to wins of self fought battles
    win_count = self.wins_attack(days_ago)
    loss_count = self.losses_attack(days_ago)
    total_battles = win_count + loss_count
    total_battles > 0 ? win_count.to_f/total_battles.to_f * 100.0 : 0
  end
  
  def win_percentage_d days_ago
    win_count = self.wins_defense(days_ago)
    loss_count = self.losses_defense(days_ago)
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
  
  def rank _
    case @rank
    when 1
      return 'Member'
    when 2
      return 'Officer'
    when 3
      return 'Leader'
    when 4
      return 'Warmaster'
    end
  end
  
  def token_claim _
    (Time.now - Time.at(@token_claim))/86400
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
