source "https://rubygems.org"

gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

# TODO: back to branch: "main" once refinery/refinerycms#3540 merges
git "https://github.com/refinery/refinerycms", ref: "fd344bb43ca6d79b7f11d34208098efd7de13163" do
  gem "refinerycms"

  group :test do
    gem "refinerycms-testing"
  end
end

gem "decorators", github: "parndt/decorators", branch: "zeitwerk"

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

gem 'json', '< 3' if ENV['RAILS_VERSION']&.match?(/^~> (6|7|8\.0)\./)

group :test do
  gem "database_cleaner-active_record"
  gem "launchy"
  gem "pry"
end

# Load local gems according to Refinery developer preference.
if File.exist? local_gemfile = File.expand_path("../.gemfile", __FILE__)
  eval File.read(local_gemfile)
end
