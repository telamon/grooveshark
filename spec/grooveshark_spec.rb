require 'spec_helper'

describe 'Grooveshark' do
  before do
    stub_request(:get, "http://grooveshark.com/").
      to_return(
        :status => 200, :body => "",
        :headers => {
          'Set-Cookie' => 'PHPSESSID=8d5e0200564abe281e7e98435e40ee16;'
        }
      )
      
    stub_request(:post, api_secure_url('getCommunicationToken')).
      to_return(
        :status => 200,
        :body => fixture('get_communication_token.json')
      )
  end

  it 'returns a new Client instance via shortcut' do
    gs = Grooveshark.new
    gs.should be_a Grooveshark::Client
    gs.session.should == '8d5e0200564abe281e7e98435e40ee16'
  end
end