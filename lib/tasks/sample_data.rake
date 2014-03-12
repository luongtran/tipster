namespace :db do
  namespace :seed do
    task :plan => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_plan.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :sport => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_sport.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :bet_type => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_bet_type.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :platform => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_platform.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :tipster => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_tipster.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :tip => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_tip.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :all => [:plan, :sport, :bet_type, :platform, :tipster]
  end
end
