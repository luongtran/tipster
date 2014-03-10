tipsters = Tipster.all
events = Event.fetch
sports = Sport.all
ActiveRecord::Base.record_timestamps = false
tipsters.each do |tipster|
  puts " ==> Generating tip for #{tipster.full_name}"
  rand_number_tips = rand(40..100)
  rand_number_tips.times do |index|
    created_at = rand(2..300).days.ago - rand(1..15).hours
    evtname = events.sample.name
    Tip.create!(
        event: evtname,
        sport_id: sports.sample.id,
        author_id: tipster.id,
        author_type: tipster.class.name,
        platform: Tip::BET_BOOKMARKERS.sample,
        expire_at: created_at + rand(1..10).hours,
        bet_type: 1,
        selection: 1,
        line: 1,
        stake: rand(1..5),
        amount: 10*rand(4..12),
        advice: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy \
         nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat',
        odds: rand(1..5.5).round(1),
        free: false,
        status: 1,
        correct: [false, true].sample,
        created_at: created_at,
        updated_at: created_at + 10.seconds,
    )
    puts " -> Tip for event #{evtname}"
  end
  puts "========================\n"
end
ActiveRecord::Base.record_timestamps = true