puts "\n==========> Starting create bookmarkers"
%w(betclic france_paris bwin unibet netbet fdj).each do |bm|
  Bookmarker.find_or_create_by(
      code: bm,
      name: bm.titleize
  )
  puts "===== Created: #{bm.titleize}"
end
puts "\n==========> Done create bookmarkers"
