%w(football tennis basketball baseball rugby hockey horse football_us).each_with_index do |name, index|
  if Sport.create(
      name: name,
      position: index + 1
  )
    puts " -> Created sport: #{name}"
  end
end
