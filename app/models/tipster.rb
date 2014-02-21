class Tipster < User

  class << self
    def initial_some_tipsters # Just for testing
      5.times do
        fn = Faker::Name.first_name
        tst = new(
            first_name: fn,
            last_name: Faker::Name.last_name,
            email: "#{fn}@gmail.com",
            password: "123456",
            password_confirmation: "123456"
        )
        tst.save!
      end
    end
  end

end
