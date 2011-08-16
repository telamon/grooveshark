require 'spec_helper'

describe 'Client' do
  before do
    stub_init_session
  end
  
  it 'has a valid session token and communication token' do
    client = Grooveshark::Client.new
    client.session.nil?.should == false
    client.session.should == '8d5e0200564abe281e7e98435e40ee16'
    client.communication_token.nil?.should == false
    client.communication_token.should == '4e38a8ae9ca3a'
  end
  
  it 'returns an empty collection if no songs were found' do
    stub_request(:post, api_url('getSearchResults')).
      to_return(
        :status => 200,
        :body => fixture('get_search_results_empty.json')
      )
      
    client = Grooveshark::Client.new
    songs = client.search_songs('Something Fake')
    songs.should be_a Array
    songs.empty?.should == true
  end
  
  it 'returns a collection of songs' do
    stub_request(:post, api_url('getSearchResults')).
      to_return(
        :status => 200,
        :body => fixture('get_search_results_songs.json')
      )
    
    client = Grooveshark::Client.new
    songs = client.search_songs('Kyte')
    songs.should be_a Array
    songs.empty?.should == false
    songs.first.should be_a Grooveshark::Song
  end
  
  it 'returns a collection of recently active users' do
    stub_request(:post, api_url('getRecentlyActiveUsers')).
      to_return(
        :status => 200,
        :body => fixture('get_recently_active_users.json')
      )
    
    client = Grooveshark::Client.new
    users = client.recently_active_users
    users.should be_a Array
    users.empty?.should == false
    users.first.should be_a Grooveshark::User
  end
  
  it 'returns a collection of popular songs' do
    stub_request(:post, api_url('popularGetSongs')).
      to_return(
        :status => 200,
        :body => fixture('popular_get_songs.json')
      )
    
    client = Grooveshark::Client.new
    songs = client.popular_songs
    songs.should be_a Array
    songs.empty?.should == false
    songs.first.should be_a Grooveshark::Song
  end
  
  it 'returns a streaming url for the song' do
    stub_request(:post, api_url('getStreamKeyFromSongIDEx')).
      to_return(
        :status => 200,
        :body => fixture('get_stream_key_from_song_id.json')
      )
    
    client = Grooveshark::Client.new
    url = client.get_song_url(10467515)
    url.nil?.should == false
    url.should match /^http:/i
  end
  
  it 'raises Grooveshark::NotFound for stream request with invalid song id' do
    stub_request(:post, api_url('getStreamKeyFromSongIDEx')).
      to_return(
        :status => 200,
        :body => fixture('failures/get_stream_key_from_song_id_ex.json')
      )
  
    proc { Grooveshark::Client.new.get_song_url(12345) }.
      should raise_error Grooveshark::NotFound
  end
  
  it 'returns a collection of suggested artists' do
    stub_request(:post, api_url('getArtistAutocomplete')).
      to_return(
        :status => 200,
        :body => fixture('get_artist_autocomplete.json')
      )
      
    client = Grooveshark::Client.new
    artists = client.get_artist_autocomplete('Nirva')
    artists.should be_a Array
    artists.first.should be_a Grooveshark::Artist
    artists.first.id.should == 57
    artists.first.name.should == 'nirvana'
  end
  
  context 'authentication' do  
    it 'returns a user on valid credentials' do
      stub_request(:post, api_secure_url('authenticateUser')).
        to_return(
          :status => 200,
          :body => fixture('authenticate_user.json')
        )
    
      user = Grooveshark::Client.new.login('username', 'password')
      user.should be_a Grooveshark::User
    end
    
    it 'raises Grooveshark::InvalidAuthentication on invalid credentials' do
      stub_request(:post, api_secure_url('authenticateUser')).
        to_return(
          :status => 200,
          :body => fixture('failures/authenticate_user.json')
        )
    
      proc { Grooveshark::Client.new.login('foo', 'bar') }.
        should raise_error Grooveshark::InvalidAuthentication
    end
  end
end
