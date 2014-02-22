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
    task :tipster => :environment do
      seed_file = File.join(Rails.root, 'db', 'seed_tipster.rb')
      load(seed_file) if File.exist?(seed_file)
    end
    task :all => [:sport, :plan, :tipster]
  end
end
