def load_seed_file(file)
  seed_file = File.join(Rails.root, 'db', 'seeds', file)
  load(seed_file) if File.exist?(seed_file)
end

namespace :db do
  namespace :seed do
    task :plan => :environment do
      load_seed_file('seed_plan.rb')
    end
    task :sport => :environment do
      load_seed_file('seed_sport.rb')
    end
    task :bookmarker => :environment do
      load_seed_file('seed_bookmarker.rb')
    end
    task :tipster => :environment do
      load_seed_file('seed_tipster.rb')
    end
    task :admin => :environment do
      load_seed_file('seed_admin.rb')
    end

    task :tip => :environment do
      load_seed_file('seed_tip.rb')
    end
    task :all => [:plan, :sport, :bookmarker, :tipster, :admin]
  end
end
