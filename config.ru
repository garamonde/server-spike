require 'bundler/setup'
require 'garamonde/app/api'
require 'garamonde/app/site'

run Rack::Cascade.new [Garamonde::Site, Garamonde::API]
