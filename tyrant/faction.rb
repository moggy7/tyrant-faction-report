# Faction object to keep track of faction members and access them easily
load 'tyrant/faction_member.rb'

class Faction

  def initialize id
    @id = id
    @members = {}
  end
  ## faction management utilities
  def add_member params
    @members[params[:id]] = FactionMember.new(params)
  end

  def find_member id
    @members[id]
  end

  def members
    @members.collect{ |id, member| member }
  end
end