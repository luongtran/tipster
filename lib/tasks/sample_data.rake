namespace :db do
  task :sample_tipster => :environment do
    seed_file = File.join(Rails.root, 'db', 'sample_tipster.rb')
    load(seed_file) if File.exist?(seed_file)
  end
  task :seed_plan => :environment do
    seed_file = File.join(Rails.root, 'db', 'seeds_plan.rb')
    load(seed_file) if File.exist?(seed_file)
  end
end
