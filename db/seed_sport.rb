%w(football tennis basketball handball rugby hockey horse football_us baseball).each_with_index do |name, index|
  if Sport.create(
      name: name,
      position: index + 1
  )
    puts " -> Created sport: #{name}"
  end
end
