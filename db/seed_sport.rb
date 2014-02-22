%w(Football Horse Tennis Basketball Baseball Rugby Football_US).each do |name|
  if Sport.create(name: name)
    puts "-> Created sport: #{name}"
  end
end
