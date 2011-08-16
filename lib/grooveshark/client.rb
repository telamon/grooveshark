module Grooveshark
  class Client
    include Grooveshark::Connection
    include Grooveshark::Request
    
    attr_accessor :session
    attr_reader   :communication_token
    attr_reader   :communication_token_ttl
    attr_reader   :user
  
    # Initialize a new Grooveshark::Client instance
    #
    # session - Valid session ID (optional)
    # 
    def initialize(session=nil)
      @session = session || request_session_token
      request_communication_token
    end
      
    # Authenticate user
    #
    # user     - Grooveshark account username
    # password - Grooveshark account password
    #
    # @return [Grooveshark::User]
    #
    def login(user, password)
      data = request('authenticateUser', {:username => user, :password => password}, true)
      @user = User.new(self, data)
      raise InvalidAuthentication, 'Wrong username or password!' if @user.id == 0
      return @user
    end
    
    # Find user by ID
    #
    # id - Grooveshark user ID
    #
    # @return [Grooveshark::User]
    #
    def get_user_by_id(id)
      resp = request('getUserByID', {:userID => id})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Find user by account username
    #
    # name - Grooveshark user username
    #
    # @return [Grooveshark::User]
    #
    def get_user_by_username(name)
      resp = request('getUserByUsername', {:username => name})['user']
      resp['username'].empty? ? nil : User.new(self, resp)
    end
    
    # Get recently active users
    #
    # @return [Array][Grooveshark::User]
    #
    def recently_active_users
      request('getRecentlyActiveUsers', {})['users'].map { |u| User.new(self, u) }
    end
    
    # Returns a collection of popular songs for the time period
    #
    # type - daily, monthly
    #
    # @return [Array][Grooveshark::Song]
    #
    def popular_songs(type='daily')
      unless ['daily', 'monthly'].include?(type)
        raise ArgumentError, "Invalid type: #{type}."
      end
      request('popularGetSongs', {:type => type})['songs'].map { |s| Song.new(self, s) }
    end
      
    # Returns a collection of songs found for query
    #
    # query - Search query (ex.: AC/DC - Back In Black)
    #
    # @return [Array][Grooveshark::Song]
    #
    def search_songs(query)
      search(:songs, query).map { |record| Song.new(self, record) }
    end
    
    alias :songs :search_songs
    
    # Returns a collection of artists
    #
    # query - Search query (ex.: AC/DC)
    #
    # @return [Array][Grooveshark::Artist]
    #
    def search_artists(query)
      search(:artists, query).map { |record| Artist.new(self, record) }
    end
    
    alias :artists :search_artists
    
    # Returns a stream authentication for song
    #
    # song - Grooveshark::Song object or ID
    #
    def get_stream_auth(song)
      song_id = song.kind_of?(Grooveshark::Song) ? song.id : song.to_s
      
      request('getStreamKeyFromSongIDEx', {
        'songID'    => song_id,
        'prefetch'  => false,
        'mobile'    => false,
        'country'   => COUNTRY
      })
    end
    
    # Returns a direct streaming url for song
    #
    # song - Grooveshark::Song object or ID
    #
    # @return [String]
    # 
    def get_song_url(song)
      auth = get_stream_auth(song)
      if auth.empty?
        raise Grooveshark::NotFound, "Invalid song ID."
      else
        "http://#{auth['ip']}/stream.php?streamKey=#{auth['stream_key']}"
      end
    end
    
    # Returns an album object
    #
    # album - Grooveshark::Album object or Album ID
    #
    # @return [Grooveshark::Album]
    #
    def get_album(album)
      id = album.kind_of?(Grooveshark::Album) ? album.id : album.to_s
      Album.new(self, request('getAlbumByID', {:albumID => id}))
    end
    
    # Returns an array of Song objects
    #
    # album - Grooveshark::Album or Album ID
    #
    # @return [Array]
    #
    def get_album_songs(album)
      id = album.kind_of?(Grooveshark::Album) ? album.id : album.to_s
      opts = {:albumID => id, :isVerified => true, :offset => 0}
      request('albumGetSongs', opts)['songs'].map { |s| Song.new(self, s) }
    end
    
    # Returns an artist object
    #
    # artist - Grooveshark::Artist or Artist ID
    #
    # @return [Grooveshark::Artist]
    #
    def get_artist(artist)
      id = artist.kind_of?(Grooveshark::Artist) ? artist.id : artist.to_s
      Artist.new(self, request('getArtistByID', {:artistID => id}))
    end
    
    # Returns a collection of artists suggested for query
    #
    # query - Search query
    #
    # @return [Array][Grooveshark::Artist]
    def get_artist_autocomplete(query)
      resp = request('getArtistAutocomplete', :query => query)
      resp['artists'].map { |a| Grooveshark::Artist.new(self, a) }
    end
    
    # Returns an array of Song objects for artist
    #
    # artist - Grooveshark::Artist object or Artist ID
    #
    # @return [Array]
    #
    def get_songs_by_artist(artist)
      id = artist.kind_of?(Grooveshark::Artist) ? artist.id : artist.to_s
      opts = {:artistID => id, :isVerifiedOrPopular => true}
      request('artistGetSongsEx', opts).map { |s| Song.new(self, s) }
    end
    
    protected
    
    # Returns a collection of search results
    #
    # type  - Search index (artists, songs)
    # query - Search query
    #
    # @return [Array]
    #
    def search(type, query)
      type = type.to_s.capitalize
      unless ['Songs', 'Artists'].include?(type)
        raise ArgumentError, "Invalid search type: #{type}."
      end    
      request('getSearchResults', {:type => type, :query => query})[type.downcase]
    end
  end
end
