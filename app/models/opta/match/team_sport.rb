module Opta
  module Match
    module TeamSport
      # Contains specify for team sports, ex: Soccer, basketball, handball, hockey ...
      included do
        def name
          "" << self.team_a_name << 'vs' << self.team_b_name
        end
      end
    end
  end
end