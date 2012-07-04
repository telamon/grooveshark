$:.unshift File.expand_path("../..", __FILE__)


require 'spec_stubs'
require 'grooveshark'
require 'pry'
describe "Live API Tests" do
	before do
		@client = Grooveshark::Client.new
	end

	it 'should have a valid Client' do		
		pp @client
		@client.session.should_not == nil
		@client.communication_token.should_not == nil
		@client.communication_token_ttl.should_not == nil

		@client.search_songs('muse').empty?.should_not == true

	# 	binding.pry
	end
end	