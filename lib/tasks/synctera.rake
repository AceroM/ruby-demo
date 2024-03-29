namespace :synctera do
  desc "Synchronize disclosures for all users"
  task sync_disclosures: [:environment] do |task, _args|
    User.find_each do |user|
      puts "Syncing disclosures for user: #{user.email}"
      if user.synctera?
        Synctera::Disclosures.sync_all(user)
        "Synced disclosures for user: #{user.email}"
      else
        puts "Synctera person not found for user: #{user.email}"
      end
    end
    puts "Disclosures synced successfully."
  end
  desc "Synchronize persons for all users"
  task sync_persons: [:environment] do |task, _args|
    User.find_each do |user|
      puts "Syncing persons for user: #{user.email}"
      if user.synctera?
        Synctera::Persons.sync(user)
      else
        puts "Synctera person not found for user: #{user.email}"
      end
    end
    puts "Persons synced successfully."
  end
end
