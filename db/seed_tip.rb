tipsters = Tipster.all
events = Event.fetch
sports = Sport.all
platforms = Platform.all

if platforms.empty?
  raise 'Can not create tip without any platforms!'
else
  ActiveRecord::Base.record_timestamps = false
  tipsters.each do |tipster|
    puts " ==> Generating tip for #{tipster.full_name}"
    rand_number_tips = rand(10..20)
    rand_number_tips.times do |index|
      created_at = rand(2..300).days.ago - rand(1..15).hours
      event = events.sample
      Tip.create!(
          event: event.name,
          sport_id: sports.sample.id,
          author_id: tipster.id,
          author_type: tipster.class.name,
          platform_id: platforms.sample.id,
          event_start_at: created_at + rand(1..5).hours,
          event_end_at: created_at + rand(6..7).hours,
          bet_type_id: 1,
          selection: event.team_a,
          line: 1,
          amount: 10*rand(4..12),
          advice: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy.',
          odds: rand(1..5.5).round(1),
          free: false,
          status: 1,
          correct: [false, true].sample,
          published_at: created_at,
          created_at: created_at,
          updated_at: created_at + 10.seconds,
      )
      puts " -> Tip for event #{event.name}"
    end
    puts "========================\n"
  end
  ActiveRecord::Base.record_timestamps = true
end

