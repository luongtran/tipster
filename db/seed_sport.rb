%w(football horse tennis basketball baseball rugby football_us).each do |name|
  if Sport.create(name: name)
    puts " -> Created sport: #{name}"
  end
end
