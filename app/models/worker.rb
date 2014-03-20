class Worker
  DAY_INTERVAL = 7
  class << self
    # Get matches on active seasons
    def update_matches
      # TODO: after get matches, try to find id on odds feed from betclic
      sports = Sport.where(name: %w(football basketball))
      # Load active seasons
      from_date = DateTime.now
      to_date = from_date + DAY_INTERVAL.days
      seasons = Season.all
      sports.each do |sport|
        seasons.each do |season|
          fetcher = OptaSport::Fetcher.send(sport.name)
          if fetcher.respond_to?(:get_matches)
            res = fetcher.get_matches(
                id: season.opta_season_id,
                type: 'season',
                start_date: from_date,
                end_date: to_date
            )
            if fetcher.success?
              matches = res.all
              matches.each do |match|
                Match.create(match.merge(sport_id: sport.id))
              end
            else
              puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
            end
          end
        end
      end
    end

    def update_seasons
      # http://api.core.optasports.com/soccer/get_seasons?authorized=yes&active=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(name: %w(football basketball))
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.name)
        if fetcher.respond_to?(:get_seasons)
          res = fetcher.get_seasons(
              authorized: 'yes',
              active: 'yes'
          )
          if fetcher.success?
            seasons = res.all
            seasons.each do |season|
              Season.create(season)
            end
          end
        end
      end

    end

    def update_competitions
      # http://api.core.optasports.com/soccer/get_competitions?authorized=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(name: %w(football basketball))
      compts = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.name)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(
              authorized: 'yes'
          )
          if fetcher.success?
            competitions = res.all
            compts += competitions
            competitions.each do |competition|
              Competition.create(competition)
            end
          else
            puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
          end
        end

      end
      compts
    end
  end
end