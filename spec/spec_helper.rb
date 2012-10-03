require "poslavu"
Bundler.require :development

require 'webmock/rspec'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure { |config|
  config.include POSLavu::APIStub
}

Dotenv.load
