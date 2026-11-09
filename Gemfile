source "https://rubygems.org"

gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

if ENV['RAILS_VERSION']&.match?(/^~> [89]\./) || ENV['RAILS_VERSION']&.match?(/^~> 7\.[2-9]/)
  git "https://github.com/refinery/refinerycms", branch: "main" do
    gem "refinerycms"

    group :test do
      gem "refinerycms-testing"
    end
  end

  # Released decorators caps railties below 7.2; refinerycms main uses this branch too
  gem "decorators", github: "parndt/decorators", branch: "zeitwerk"
else
  gem "refinerycms", "4.1.0"

  group :test do
    gem "refinerycms-testing", "4.1.0"
  end
end

# Database Configuration
if !ENV["CI"] || ENV["DB"] == "sqlite3"
  gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
  gem "sqlite3", :platform => :ruby
end

if !ENV["CI"] || ENV["DB"] == "mysql"
  gem "activerecord-jdbcmysql-adapter", :platform => :jruby
  gem "jdbc-mysql", "= 5.1.13", :platform => :jruby
  gem "mysql2", :platform => :ruby
end

if !ENV["CI"] || ENV["DB"] == "postgresql"
  gem "activerecord-jdbcpostgresql-adapter", :platform => :jruby
  gem "pg", :platform => :ruby
end

gem "jruby-openssl", :platform => :jruby

group :assets do
  gem "sass-rails"
  gem "coffee-rails"
  gem "uglifier"
end

gem 'listen'

# Ruby 3.4+ extracted mutex_m from stdlib, but older Rails versions need it
gem 'mutex_m' if RUBY_VERSION >= '3.4' && ENV['RAILS_VERSION']&.match?(/^~> [67]\./)

group :test do
  gem "database_cleaner-active_record"
  gem "launchy"
  gem "pry"
end

# Load local gems according to Refinery developer preference.
if File.exist? local_gemfile = File.expand_path("../.gemfile", __FILE__)
  eval File.read(local_gemfile)
end
