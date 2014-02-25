# Generate 10 tipsters
sports = Sport.all.to_a
if sports.empty?
  puts "Error! There are no any sports!"
else
  10.times do
    fn = Faker::Name.first_name
    tst = Tipster.new(
        first_name: fn,
        last_name: Faker::Name.last_name,
        email: "#{fn}@fakemail.com",
        password: "123456",
        password_confirmation: "123456",
        sport: sports.sample
    )
    if tst.save
      puts " -> Created tipster: #{tst.name}"
    end
  end
end
