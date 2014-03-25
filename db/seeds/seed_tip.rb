puts "\n==========> Starting create tips"
tipsters = Tipster.all
betclic_platform = Platform.first

admins = Admin.all

ActiveRecord::Base.record_timestamps = false
puts "\n===> Creating tips ==================="
tipsters.each do |tipster|
  puts " ==> Tipster [#{tipster.id}] #{tipster.full_name}"
  tipster_created_at = tipster.created_at
  start_date = tipster_created_at.to_date + 1.days
  end_date = Date.today - 1.days
  sports_of_tipsters = tipster.sports
  date_have_tip = start_date

  while date_have_tip < end_date
    number_tips_on_the_date = rand(1..2)
    sport_of_tip = sports_of_tipsters.sample
    bet_types_of_tip = sport_of_tip.bet_types
    available_matches_at_this_time = sport_of_tip.matches.where(start_at: (date_have_tip.end_of_day)..((date_have_tip + 3.days).end_of_day))
    matchs_for_tips = available_matches_at_this_time.sample(number_tips_on_the_date)

    matchs_for_tips.each do |match|
      bet_type = bet_types_of_tip.sample
      created_at = date_have_tip.beginning_of_day + rand(11..777).minutes
      tip = Tip.new(
          match_id: match.opta_match_id,
          sport_id: sport_of_tip.id,
          author_id: tipster.id,
          author_type: tipster.class.name,
          platform_id: betclic_platform.id,
          bet_type_id: bet_type.id,
          selection: [match.team_a, match.team_b, 'Draw', "#{%w(Over Under).sample} #{[1, 1.5, 3.5, 4, 2, 3.5].sample}"].sample,
          amount: 10*rand(1..10),
          advice: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy.',
          odds: rand(1..5.5).round(1),
          free: false,
          status: Tip::STATUS_FINISHED,
          correct: [false, true].sample,
          published_at: created_at + rand(1..3).hours + rand(10..30).minutes,
          published_by: admins.sample.try :id,
          created_at: created_at,
          updated_at: created_at,
      )
      if bet_type.has_line?
        tip.line = rand(5..15)
      end
      if tip.save
        puts " -> Created tip for match: #{match.name}"
      else
        puts " -> Error create tip: #{tip.errors.full_messages}"
      end
    end
    # Go to the next day
    date_have_tip += rand(1..2).days
  end
end
ActiveRecord::Base.record_timestamps = true
puts "\n==========> Done create tips"
