class SystemJournal < ActiveRecord::Base

  EVENTS = [
      # Update the statistics about profit, yield, sports, bet types ... for all tispters
      EVT_UPDATE_TIPSTER_STATISTICS = {
          code: 'update_tipster_statistics',
          name: 'Update tipster statistics'
      },

      # Update new info for all matches (played, cancelled, score ...)
      EVT_UPDATE_MATCHES = {
          code: 'update_bookmarker_matches',
          name: 'Update bookmarker matches'
      },

      # Send sms and email
      EVT_PUBLISHED_TIP = {
          code: 'update_bookmarker_matches',
          name: 'Update bookmarker matches'
      }
  ]

  class << self
    def write_event(event)
      event = self.new(

      )
    end

    def clean_up(keep = 5)
    end
  end

end