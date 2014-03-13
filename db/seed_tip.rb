tipsters = Tipster.all
platforms = Platform.all

if platforms.empty?
  raise 'Can not create tip without any platforms!'
else
  ActiveRecord::Base.record_timestamps = false
  puts "\n===> Creating tips ==================="
  tipsters.each do |tipster|
    puts " ==> Tipster [#{tipster.id}] #{tipster.full_name}"
    tipster_created_at = tipster.created_at
    start_date = tipster_created_at.to_date + 1.days
    end_date = Date.today - 3.days
    sports_of_tipsters = tipster.sports
    date_have_tip = start_date
    while date_have_tip < end_date
      number_tips_on_the_date = rand(1..2)
      sport_of_tip = sports_of_tipsters.sample
      events = Event.fetch(sport_of_tip.name)
      bet_types_of_tip = sport_of_tip.bet_types

      number_tips_on_the_date.times do
        bet_type = bet_types_of_tip.sample
        created_at = date_have_tip.beginning_of_day + rand(10..600).minutes
        event = events.sample
        unless event.nil?
          tip = Tip.new(
              event: event.name,
              sport_id: sport_of_tip.id,
              author_id: tipster.id,
              author_type: tipster.class.name,
              platform_id: platforms.sample.id,

              event_start_at: created_at + rand(1..5).hours,
              bet_type_id: bet_type.id,
              selection: [event.team_a, event.team_b, 'Draw'].sample,
              amount: 10*rand(4..12),
              advice: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy.',
              odds: rand(1..5.5).round(1),

              free: false,
              status: Tip::STATUS_APPROVED,
              correct: [false, true].sample,
              published_at: created_at + rand(1..3).hours + rand(10..30).minutes,
              created_at: created_at,
              updated_at: created_at,
          )
          if bet_type.has_line?
            tip.line = rand(5..15)
          end
          tip.save!
        end
        puts " -> Tip for event #{event.try(:name)}"
      end

      # Go to the next day
      date_have_tip += rand(1..4).days
    end
  end
  ActiveRecord::Base.record_timestamps = true
end

