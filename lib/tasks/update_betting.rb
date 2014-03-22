namespace :betting do
  namespace :update do
    task :competitions => :environment do
      puts "\n ====> Starting update Competitions data ========"
      Worker.update_competitions
      puts "\n ====> Done update Competitions data ========"
    end
    task :seasons => :environment do
      puts "\n ====> Starting update Seasons data ========"
      Worker.update_seasons
      puts "\n ====> Done update Seasons data ========"
    end
    task :matches => :environment do
      puts "\n ====> Starting update Matches data ========"
      Worker.update_matches
      puts "\n ====> Done update Matches data ========"
    end
    task :all => [:competitions, :seasons, :matches]
  end
end