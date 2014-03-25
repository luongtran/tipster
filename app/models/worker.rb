class Worker
  DAY_INTERVAL = 7
  class << self
    # Get matches on active seasons
    # http://api.core.optasports.com/soccer/get_matches?type=season&id=8318&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
    def update_matches
      # TODO: after get matches, try to find id on odds feed from betclic
      sports = Sport.where(code: %w(soccer basketball))
      # Load active seasons
      from_date = DateTime.now
      to_date = from_date + DAY_INTERVAL.days

      sports.each do |sport|
        seasons = sport.seasons
        seasons.each do |season|
          fetcher = OptaSport::Fetcher.send(sport.code)
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
      # Option: id=13&type=competition

      founded_seasons = []
      competitions = Competition.all

      competitions.each do |competition|
        sport = competition.sport
        fetcher = OptaSport::Fetcher.send(sport.code)

        if fetcher.respond_to?(:get_seasons)
          res = fetcher.get_seasons(
              id: competition.opta_competition_id,
              type: 'competition',
              authorized: 'yes',
              active: 'yes'
          )
          if fetcher.success?
            founded_seasons += res.all
          end
        end

        # Saving to DB
        founded_seasons.each do |season_attrs|
          Season.create(season_attrs)
        end
      end

    end

    def update_competitions
      # http://api.core.optasports.com/soccer/get_competitions?authorized=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      sports = Sport.where(code: %w(soccer basketball tennis))
      compts = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.code)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(
              authorized: 'yes'
          )
          if fetcher.success?
            competitions = res.all
            compts += competitions
            competitions.each do |competition|
              Competition.create(
                  competition.merge(sport_id: sport.id)
              )
            end
          else
            puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
          end
        end
      end
      compts
    end

    def old_matches
      require 'csv'
      sports = Sport.where("code in (?)", ['soccer', 'basketball'])
      # Load active seasons
      end_date = Date.today
      founded_matches = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.send(sport.code)
        sport.seasons.each do |season|
          # Initial fetcher
          # Start fetching
          if fetcher.respond_to?(:get_matches)
            res = fetcher.get_matches(
                id: season.opta_season_id,
                type: 'season',
                end_date: end_date.to_s
            )
            if fetcher.success?
              founded_matches += res.all.map do |match_attrs|
                match_attrs.merge(sport_id: sport.id)
              end
            else
              puts "Error: #{res.message}; \n URL: #{fetcher.last_url}"
            end
          end

        end # End seasons
      end

      founded_matches.each do |match_attrs|
        Match.create! match_attrs
      end
      founded_matches
    end


    def update_areas
      # Soccer for full of areas
      fetcher = OptaSport::Fetcher.soccer
      res = fetcher.get_areas
      res.all.each do |area_attrs|
        Area.create area_attrs
      end
    end
  end # End class block

end