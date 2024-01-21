class Scripts < Thor
  include Thor::Actions

  desc "reset", "drop and create database, then run migrations"

  def reset
    system "dropdb ruby-demo_development"
    system "createdb ruby-demo_development"
    system "rails db:migrate"
  end

  desc "test", "testing out thor commands"

  def test
    gsub_file "config/environments/development.rb", /config\.cache_store = :null_store/, "config.cache_store = :memory_store"
  end
end
