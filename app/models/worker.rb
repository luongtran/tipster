class Worker
  DAY_INTERVAL = 7
  class << self
    # Get matches by seasons
    # http://api.core.optasports.com/soccer/get_matches?type=season&id=8318&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
    def update_matches
      sports = Sport.includes(:seasons).where(code: OptaSport::AVAILABLE_SPORT)
      # Load active seasons
      from_date = DateTime.now
      to_date = from_date + DAY_INTERVAL.days
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.find_fetcher_for(sport.code)
        if fetcher && fetcher.respond_to?(:get_matches)
          seasons = sport.seasons
          seasons.each do |season|
            res = fetcher.get_matches(
                id: season.opta_season_id,
                type: 'season',
                start_date: from_date,
                end_date: to_date
            )
            if fetcher.success?
              res.all.each do |match|
                Match.create(match.merge(sport_code: sport.code))
              end
            else
              puts fetcher.error.log_format
            end
          end # End season
        end
      end # End sport
    end

    def get_match_details(opta_match_id)
      fetcher = OptaSport::Fetcher.soccer
      fetcher.get_matches(
          id: opta_match_id
      )
    end

    def update_seasons
      # http://api.core.optasports.com/soccer/get_seasons?authorized=yes&active=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
      # Option: id=13&type=competition

      founded_seasons = []
      competitions = Competition.all

      competitions.each do |competition|
        fetcher = OptaSport::Fetcher.find_fetcher_for(competition.sport_code)
        if fetcher.respond_to?(:get_seasons)
          res = fetcher.get_seasons(
              id: competition.opta_competition_id,
              type: 'competition',
              authorized: true,
              active: true
          )
          if fetcher.success?
            founded_seasons += res.all
          else
            puts fetcher.error.log_format
          end
        end

        # Saving to DB
        founded_seasons.each do |season_attrs|
          Season.create season_attrs
        end
      end
      founded_seasons
    end

    def update_france_name_for_competitions
      sports = Sport.where(code: OptaSport::AVAILABLE_SPORT)
      compts = []
      sports.each do |sport|
        fetcher = OptaSport::Fetcher.find_fetcher_for(sport.code)
        if fetcher.respond_to?(:get_competitions)
          res = fetcher.get_competitions(
              authorized: true,
              lang: 'fr'
          )
          if fetcher.success?
            competitions = res.all
            competitions.each do |competition_attrs|
              compt = Competition.find_by(opta_competition_id: competition_attrs[:opta_competition_id])
              if compt
                compt.update_column :fr_name, competition_attrs[:name]
              end
            end
          else
            puts fetcher.error.log_format
          end
        end
      end
      compts
    end

    def old_matches
      sports = Sport.where(code: OptaSport::AVAILABLE_SPORT)
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
                match_attrs.merge(sport_code: sport.code)
              end
            else
              puts fetcher.error.log_format
            end
          end
        end # End seasons
      end
      founded_matches.each do |match_attrs|
        Match.create match_attrs
      end
      founded_matches
    end

    def update_areas
      fetcher = OptaSport::Fetcher.soccer
      res = fetcher.get_areas
      res.all.each do |area_attrs|
        Opta::Area.create area_attrs
      end
    end

    def update_france_name_for_areas
      fetcher = OptaSport::Fetcher.soccer
      res = fetcher.get_areas(lang: 'fr')
      res.all.each do |area_attrs|
        area = Area.find_by(opta_area_id: area_attrs[:opta_area_id])
        if area
          area.update_attribute :fr_name, area_attrs[:name]
        end
      end
    end

    def update_bookmarkers_matches
      Bookmarker.able_to_odds_feed.each do |bookmarker|
        bookmarker.get_matches
      end
    end

    def update_tipster_statistics
      TipsterStatistics.update_all_statistics
    end
  end
end