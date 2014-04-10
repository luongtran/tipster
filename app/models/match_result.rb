class MatchResult
  attr_accessor :winner, # draw, team_B, team_A, yet unknown
                :fs_team_a, :hts_team_a,
                :fs_team_b, :hts_team_b,
                :minute # current minute in-play
end