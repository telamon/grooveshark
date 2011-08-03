$:.unshift File.expand_path("../..", __FILE__)

require 'webmock'
require 'webmock/rspec'
require 'grooveshark'

def fixture_path(file=nil)
  path = File.expand_path("../fixtures", __FILE__)
  path = File.join(path, file) unless file.nil?
  path
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def json_fixture(file)
  MultiJson.decode(fixture(file))
end