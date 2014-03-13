class Event
  attr_accessor :team_a, :team_b, :time, :tournament, :league, :name, :teams

  def initialize(attrs = {})
    attrs ||= {}
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
    return self
  end

  class << self
    def fetch(sport)
      file = File.join(Rails.root, 'db', "sample_matches_csv", "#{sport}.csv")
      puts file

      events_result = []
      require 'csv'
      if File.exists?(file)
        CSV.foreach(file, :headers => true) do |row|
          evnt = Event.new(row.to_hash)
          evnt.team_a = evnt.teams.split('|').first
          evnt.team_b = evnt.teams.split('|').last
          events_result << evnt
        end
      else
        puts "File doesn't exist!"
      end

      #require 'open-uri'
      #sport = (sport == 'football') ? 'soccer' : sport
      #doc = Nokogiri::XML(open("http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=#{sport}"))
      #
      #events = doc.xpath("//event")
      #events.each_with_index do |evt, i|
      #  eve = {}
      #  eve[:time] = evt.xpath("event_datetimeGMT").text
      #  eve[:tournament] = evt.xpath("league").text
      #  eve[:live] = evt.xpath("IsLive").text
      #  three_ways = evt.xpath("participants//participant")
      #  eve[:team_a] = three_ways[0].xpath("participant_name").text
      #  eve[:team_b] = three_ways[1].xpath("participant_name").text
      #  re_events << new(eve)
      #end

      # ============ Randomize
      #15.times do
      #  re_events << new(
      #      team_a: rand_team_a,
      #      team_b: rand_team_b,
      #      tournament: rand_tournament,
      #      time: (120..1200).to_a.sample.minutes.from_now
      #  )
      #end
      # ============ End of randomize
      events_result
    end

    def rand_team_a
      ['Arsenal',
       'Aston Villa',
       'Barnsley',
       'Birmingham City',
       'Blackburn Rovers',
       'Blackpool',
       'Bolton Wanderers',
       'Bradford City',
       'Burnley',
       'Cardiff City',
       'Chelsea',
       'Coventry City',
       'Crystal Palace',
       'Derby County',
       'Everton',
       'Fulham',
       'Hull City',
       'Ipswich Town',
       'Leeds United',
       'Leicester City',
       'Liverpool'
      ].sample
    end

    def rand_tournament
      ['Premier League', 'Chamoion League', 'Seria'].sample
    end

    def rand_team_b
      ['Manchester City',
       'Manchester United',
       'Middlesbrough',
       'Newcastle United',
       'Norwich City',
       'Nottingham Forest',
       'Queens Park',
       'Reading',
       'Sheffield United',
       'Southampton',
       'Stoke City',
       'Sunderland',
       'Swansea City',
       'Swindon Town',
       'Tottenham Hotspur',
       'West Bromwich',
       'Wigan Athletic'
      ].sample
    end

    def events_for_sport(sport)
      case sport
        when 'football'
        when 'tennis'
        when 'basketball'
        when 'handball'
        when 'rugby'
        when 'hockey'
        when 'horse_racing'
        when 'football_us'
        when 'baseball'
      end
    end

  end
end
