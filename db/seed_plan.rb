Plan.delete_all
p1 = Plan.create!(
    title: 'Basic',
    :price => 0,
    :reception_delay => 1,
    :number_tipster => 1,
    :pause_ability => false,
    :switch_tipster_ability => false,
    :profit_guaranteed => false,
    :period => 0
)
puts " -> Created plan: #{p1.title}"

p2 = Plan.create!(
    title: '1 Month',
    :price => 39.90,
    :number_tipster => 1,
    :profit_guaranteed => false,
    :switch_tipster_ability => false,
    :period => 1
)
puts " -> Created plan: #{p2.title}"

p3 = Plan.create!(
    title: '3 Month',
    :price => 34.90,
    :number_tipster => 1,
    :switch_tipster_ability => false,
    :period => 3
)
puts " -> Created plan: #{p3.title}"

p4 = Plan.create!(
    title: '12 Month',
    :price => 24.90,
    :number_tipster => 1,
    :switch_tipster_ability => true,
    :period => 12
)
puts " -> Created plan: #{p4.title}"

p5 = Plan.create!(
    title: 'Multi tipster',
    :price => 59.90,
    :number_tipster => 5,
    :switch_tipster_ability => false,
    :period => 1
)
puts " -> Created plan: #{p5.title}"
puts "Seed plans completed!"