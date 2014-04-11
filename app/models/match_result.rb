class MatchResult
  attr_accessor :status, :winner, # draw, team_b, team_a, yet unknown
                :fs_team_a, :hts_team_a, :team_a,
                :fs_team_b, :hts_team_b, :team_b,
                :minute # current minute in-play
  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end

  def winner
    if @winner == 'team_A'
      @team_a
    elsif @winner == 'team_B'
      @team_b
    elsif @winner == "draw"
      'Draw'
    else
      'Unknown'
    end
  end

  def ft_score
    "#@fs_team_a - #@fs_team_b"
  end

  def ht_score
    "#@hts_team_a - #@hts_team_b"
  end
end