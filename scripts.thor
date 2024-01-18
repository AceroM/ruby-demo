class Scripts < Thor
  desc "reset", "drop and create database, then run migrations"

  def reset
    system "dropdb ruby-demo_development"
    system "createdb ruby-demo_development"
    system "rails db:migrate"
  end
end
