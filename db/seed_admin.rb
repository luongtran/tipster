puts "\n===> Creating admin accounts ==================="
2.times do |i|
  admin = Admin.new(
      full_name: "Admin",
      account_attributes: {
          email: "admin#{i+1}@fakemail.com",
          password: "123456",
          password_confirmation: "123456"
      }
  )
  admin.account.skip_confirmation!
  if admin.save
    puts " ==> Created: #{admin.account.email}"
  else
    puts " ==> Created admin account failed: #{admin.errors.full_messages} "
  end
end
puts "===> Done admin accounts ==================="