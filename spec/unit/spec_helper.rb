# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rspec/its'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
    c.verify_doubled_constant_names = true
  end
end

# Helper to simulate Server Responses. Parses the fixtures in the spec folder
def server_response(path)
  JSON.parse(File.readlines("spec/fixtures/#{path}.json").join)
end

ARANGO_HOST = 'http://localhost:8529'
