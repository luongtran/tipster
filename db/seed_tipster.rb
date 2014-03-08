# Generate 10 tipsters
sports = Sport.all.to_a
if sports.empty?
  puts "Error! There are no any sports!"
else
  15.times do
    fn = Faker::Name.first_name
    tipser = Tipster.new(
        display_name: fn,
        full_name: "#{fn} #{Faker::Name.last_name}",
        account_attributes: {
            email: "#{fn}@fakemail.com",
            password: "123456",
            password_confirmation: "123456"
        }
    )
    tipser.account.skip_confirmation!
    if tipser.save
      sport = sports.sample
      puts " -> Created tipster: #{tipser.full_name}"
      tipser.sports << sport
    else
      puts " -> Failed: #{tipser.errors.full_messages}"
    end
  end
end