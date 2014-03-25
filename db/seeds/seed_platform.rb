puts "\n==========> Starting create platforms"
Platform.delete_all
%w(betclic bwin unibet netbet france_paris fdj).each do |pf|
  Platform.create!(
      code: pf,
      name: pf.titleize
  )
  puts "===== Created: #{pf.titleize}"
end
puts "\n==========> Done create platforms"
