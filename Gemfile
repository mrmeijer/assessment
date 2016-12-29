# Gemfile
source 'https://rubygems.org' do
  require 'json'
  require 'optparse'
  gem 'aws-sdk'

  # needed for code quality check not for run-time
  group :pre_production do
    gem 'rspec'
    gem 'rubocop', '~> 0.46.0', require: false
  end
end
