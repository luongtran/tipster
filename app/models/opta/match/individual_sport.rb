module Opta
  module Match
    module IndividualSport
      # Contains specify for individual sports, ex: Tennis, Badminton
      included do
        def name
          "" << self.person_a_name << 'vs' << self.person_b_name
        end
      end
    end
  end
end