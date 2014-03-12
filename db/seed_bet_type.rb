puts "\n==> Creating bet types =======================\n"
sports = Sport.all
if sports.empty?
  raise 'Cannot create bet types without any sports.'
else
  BetType.destroy_all
  bts = YAML.load_file("#{Rails.root}/db/bet_types.yml").symbolize_keys
  sports.each do |sport|
    puts "\n--- Create bet types for #{sport.name.titleize}"
    bet_types_for_current_sport = bts[sport.name.to_sym]
    bet_types_for_current_sport.each do |bet_type_attrs|
      bet_type_attrs.symbolize_keys!
      has_line = true
      if bet_type_attrs[:line] == 'no'
        has_line = false
      end
      new_bet_type = BetType.new(
          sport: sport,
          code: bet_type_attrs[:code],
          name: bet_type_attrs[:name],
          has_line: has_line
      )
      new_bet_type.save!
      puts "----- #{new_bet_type.name}"
    end
  end
  puts "==> Seed bet types completed!\n"
end

