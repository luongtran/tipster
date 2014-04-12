class Worker
  DAY_INTERVAL = 7
  class << self
    def update_matches

    end

    def update_tipster_statistics
      TipsterStatistics.update_all_statistics
    end
  end # End class block
end