puts "\n==========> Starting create tipster accounts"
PASSWORD = '123456'
sports = Sport.all.to_a
if sports.empty?
  puts "Error! Not found any sports."
else
  ActiveRecord::Base.record_timestamps = false
  25.times do
    created_at = rand(200..350).days.ago - rand(1..15).hours
    fn = Faker::Name.first_name
    tipser = Tipster.new(
        display_name: fn,
        full_name: "#{fn} #{Faker::Name.last_name}",
        account_attributes: {
            email: "#{fn}@fakemail.com",
            password: PASSWORD,
            password_confirmation: PASSWORD
        },
        created_at: created_at,
        updated_at: created_at
    )
    tipser.account.skip_confirmation!
    if tipser.save # Add sport for tipster
      # Any tipster are have football
      football_sport = Sport.find_by(code: 'soccer')
      tipser.sports << football_sport if football_sport
      # Add more sport for tipster
      sports_of_tipster = sports.sample(rand(2..3))
      tipser.sports << sports_of_tipster.delete_if { |sport| sport.code == 'soccer' }
      puts "===== Created tipster: #{tipser.full_name} with sports: #{tipser.sports.map { |s| s.name.titleize }.join(' | ')}"
    end

  end
  ActiveRecord::Base.record_timestamps = true
end
puts "\n==========> Done create tipster accounts"