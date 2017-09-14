# Refinery CMS Authentication Extension for Devise [![Build Status](https://travis-ci.org/refinery/refinerycms-authentication-devise.svg?branch=master)](https://travis-ci.org/refinery/refinerycms-authentication-devise)

This extension allows you to use Devise with Refinery CMS 4.0 and later.

## Usage

Simply put this in the Gemfile of your Refinery application:

```ruby
gem 'refinerycms-authentication-devise', '~> 2.0.0'
```

Then run `bundle install` to install it.

## Installation

If you're moving from a pre-3.0 release of Refinery, you lost authentication when it moved out of RefineryCMS core. After installing this gem, follow these steps to migrate old user data and re-enable authentication.

### Generate and run migrations

```sh
rails g refinery:authentication:devise  # Generate migrations
rake db:migrate                         # Run migrations
```

### Set up your new initializer

You might have old data in `initializers/refinery/authentication.rb`. The new initializer is located in `initializers/refinery/authentication/devise.rb`.

Make sure `devise.rb` is configured correctly, then delete `authentication.rb`.

Then restart your server.

## Contributing

Please see the [contributing.md](contributing.md) file for instructions.
