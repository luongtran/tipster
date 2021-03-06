puts "\n==========> Starting create sport and bet types\n\n"
Sport.delete_all
BetType.delete_all

sports_bet_types = YAML.load_file(File.join(Rails.root, 'db', 'seeds', 'sports_bet_types.yml'))

sports_bet_types.each_with_index do |sport, index|
  sport.symbolize_keys!
  new_sport = Sport.find_or_create_by(code: sport[:code], name: sport[:name])
  puts "===== Sport: #{new_sport.name}"
  bet_types = sport[:bet_types]
  bet_types.each do |bet_type_attrs|
    bet_type_attrs.symbolize_keys!
    has_line = true
    if bet_type_attrs[:line] == 'no'
      has_line = false
    end
    new_bet_type = BetType.create!(
        sport_code: new_sport.code,
        code: bet_type_attrs[:code],
        name: bet_type_attrs[:name],
        has_line: (bet_type_attrs[:line] == 'yes'),
        example: bet_type_attrs[:example],
    )
    puts "= Bet type: #{new_bet_type.name}"
  end
end
puts "\n==========> Done create sport and bet types"