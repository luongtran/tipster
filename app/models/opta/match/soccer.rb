class Opta::Match::Soccer < Opta::Match::Match
  class << self

    # Soccer#get_matches_live params instruction
    # now_playing	  only get current matches, either 'yes' or 'no', defaults to 'no'
    # date	    	  date to get live matches from, may not be more than three days away or in the past, format 'yyyy-mm-dd', defaults to today
    # lang	        two-character language code, defaults to 'en'
    # minutes	      if you want to get actual game minute and extra minute, this works in a combination with now_playing=yes
    # detailed	    Whether detailed match descriptions should be returned. Either 'yes' or 'no' (default 'yes')
    # id	          Optional id, in combination with type. If not specified, all subscribed live matches are returned
    # type	      	Either 'area', 'season' or 'match', to be used in conjunction with id.
    #
    def get_live_matches
      fetcher = OptaSport::Fetcher.soccer
      res = fetcher.get_matches_live
      if fetcher.success?
        match = res.all
      else
      end
    end
  end
end
