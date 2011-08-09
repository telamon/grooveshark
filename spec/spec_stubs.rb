# Initialization requests stubs
#
def stub_init_session
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