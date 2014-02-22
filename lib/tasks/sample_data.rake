namespace :db do
  task :generate_tipsters => :environment do
    10.times do
      fn = Faker::Name.first_name
      tst = Tipster.new(
          first_name: fn,
          last_name: Faker::Name.last_name,
          email: "#{fn}@gmail.com",
          password: "123456",
          password_confirmation: "123456"
      )
      if tst.save
        puts " -> Created tipster: #{tst.name}"
      end
    end
  end
end
