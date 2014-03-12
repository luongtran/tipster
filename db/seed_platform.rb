puts "==> Create platforms ======================="
Platform.delete_all
%w(betclic bwin unibet netbet france_paris fdj).each do |pf|
  Platform.create!(
      code: pf,
      name: pf.titleize
  )
  puts "Created: #{pf.titleize}"
end
