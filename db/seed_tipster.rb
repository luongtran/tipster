# Generate 10 tipsters
sports = Sport.all.to_a
if sports.empty?
  puts "Error! There are no any sports!"
else
  ActiveRecord::Base.record_timestamps = false
  created_at = rand(100..222).days.ago - rand(1..15).hours
  puts "\n===> Creating tipsters ==================="
  50.times do
    fn = Faker::Name.first_name
    tipser = Tipster.new(
        display_name: fn,
        full_name: "#{fn} #{Faker::Name.last_name}",
        account_attributes: {
            email: "#{fn}@fakemail.com",
            password: "123456",
            password_confirmation: "123456"
        },
        created_at: created_at,
        updated_at: created_at
    )
    tipser.account.skip_confirmation!
    tipser.save
    # Add sport for tipster
    sports_of_tipster = sports.sample(rand(1..3))
    tipser.sports << sports_of_tipster
    puts " -> Created tipster: #{tipser.full_name} -> sports: #{sports_of_tipster.map { |s| s.name.titleize }.join(',')}"
  end
  puts "\n===> Done tipsters seeds ==================="
  ActiveRecord::Base.record_timestamps = true
end