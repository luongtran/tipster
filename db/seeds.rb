#Plan.create!(:name => 'ZERO',title: 'Free',:price => 0 ,:number_tipster => 1,:pause_ability => false,:switch_tipster_ability => false,:profit_guaranteed => false)
#Plan.create!(:name => 'ONE',title: '1 Month', :price => 39.90 ,:number_tipster => 1)
#Plan.create!(:name => 'TWO',title: '3 Month', :price => 34.90 ,:number_tipster => 1)
#Plan.create!(:name => 'THREE',title: '12 Month', :price => 24.90 ,:number_tipster => 1)
#Plan.create!(:name => 'FOUR',title: '1 Month (multi tipster)', :price => 59.90 ,:number_tipster => 5)
#
#10.times do |i|
#  Tipster.create!(:first_name => "Pro", :last_name => "Tipster#{i}",:email => "tipster#{i}@herotipster.com",:password => '123456',:password_confirmation => '123456')
#end
Plan.find(1).update_attributes(period: 0)
Plan.find(2).update_attributes(period: 1)
Plan.find(3).update_attributes(period: 3)
Plan.find(4).update_attributes(period: 12)
Plan.find(5).update_attributes(period: 1)
