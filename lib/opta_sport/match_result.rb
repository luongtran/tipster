module OptaSport
  module MatchResult
    class Base
      attr_accessor :xml_doc, :opta_match_id

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end
    end

    module Soccer
      class SoccerMatchStatistics
        #def initialize(xml_doc)
        #  super
        #end

      end
    end

    class Tennis
    end
    class Basketball
    end
  end
end