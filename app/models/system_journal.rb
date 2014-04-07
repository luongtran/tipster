=begin
  t.string :code
  t.string :name
  t.date_time :start_at
  t.date_time :end_at
  t.boolean :success, default: true
=end
class SystemJournal < ActiveRecord::Base

  EVENTS = [
      # Update the statistics about profit, yield, sports, bet types ... for all tispters
      EVENT_UPDATE_TIPSTER_STATISTICS = {
          code: 'update_tipster_statistics',
          name: 'Update tipster statistics'
      },

      # Update new info for all matches (played, cancelled, score ...)
      EVENT_UPDATE_MATCHES = {
          code: 'update_matches',
          name: 'Update matches'
      },

      # Check the match is played, cancelled ...
      EVENT_UPDATE_TIPS = {
          code: 'update_tips',
          name: 'Update tips'
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