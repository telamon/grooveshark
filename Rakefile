require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test) do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

task :install do
  require './lib/grooveshark/version'
  
  puts "> Uninstalling gem..."
  puts `gem uninstall grooveshark --version=#{Grooveshark::VERSION}`
  
  puts "> Building gem..."
  puts `gem build grooveshark.gemspec`
  
  puts "> Installing gem..."
  puts `gem install grooveshark-#{Grooveshark::VERSION}.gem`
end

task :default => :test