=begin
  t.string    :kind
  t.datetime  :start_at
  t.datetime  :stop_at
  t.boolean   :is_done           ;default by FALSE
=end

class SystemJournal
  TYPES = %w(update_tipster_statistics update_matches update_tips)
end