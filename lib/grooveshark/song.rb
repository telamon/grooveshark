module Grooveshark
  class Song
    attr_reader :id, :artist_id, :album_id
    attr_reader :name, :artist, :album, :track, :year
    attr_reader :duration, :artwork, :playcount
    
    # Initialize a new Grooveshark::Song object
    #
    # client - Grooveshark::Client
    # data   - Song data hash
    #
    def initialize(client, data=nil)
      unless client.kind_of?(Grooveshark::Client)
        raise ArgumentError, "Grooveshark::Client required!"
      end
      
      @client = client
      unless data.nil?
        @id         = data['song_id']
        @name       = data['song_name'] || data['name']
        @artist_id  = data['artist_id']
        @album_id   = data['album_id']
        @track      = data['track_num']
        @duration   = data['estimate_duration']
        @artwork    = data['cover_art_filename']
        @playcount  = data['song_plays']
        @year       = data['year']
        
        # initialize album and artist objects from given hash
        # the format of the incoming fields is the same as it
        # is in the single requests, so its fine.
        
        if data.key?('album_id') && data.key?('album_name')
          @album = Grooveshark::Album.new(@client, data)
        end
        
        if data.key?('artist_id') && data.key?('artist_name')
          @artist = Grooveshark::Artist.new(@client, data)
        end
      end
    end
    
    # Returns a string representation of song
    #
    def to_s
      "#{@name} - #{@artist}"
    end
    
    # Returns a hash formatted for API usage
    # 
    def to_hash
      {
        'songID'      => @id,
        'songName'    => @name,
        'artistName'  => @artist,
        'artistID'    => @artist_id,
        'albumName'   => @album,
        'albumID'     => @album_id,
        'track'       => @track
      }
    end
    
    # Returns an artist object for the song
    #
    # @return [Grooveshark::Artist]
    #
    def artist
      @artist ||= @client.get_artist_by_id(@artist_id)
    end
    
    # Returns an album object for the song
    #
    # @return [Grooveshark::Album]
    #
    def album
      @album ||= @client.get_album_by_id(@album_id)
    end
    
    # Returns a direct streaming URL for the song
    #
    # @return [String]
    #
    def stream_url
      @stream_url ||= @client.get_song_url(self)
    end
  end
end
