module Grooveshark
  class Album
    attr_reader :id, :album_id, :album_name_id, :name
    attr_reader :artist_id, :year, :cover_art_filename
    attr_reader :artist_name, :is_verified
    attr_reader :songs
    attr_reader :artwork_filename
    
    # Initialize a new Grooveshark::Album object
    #
    # client - Grooveshark::Client
    # data   - Album data hash
    #
    def initialize(client, data=nil)
      unless client.kind_of?(Grooveshark::Client)
        raise ArgumentError, "Grooveshark::Client required!"
      end
      
      @client = client
      unless data.nil?
        @id                   = data['album_id'].to_i
        @name_id              = data['album_name_id'].to_i
        @name                 = data['album_name'] || data['name']
        @artist_id            = data['artist_id'].to_i
        @year                 = data['year']
        @artist_name          = data['artist_name']
        @is_verified          = data['album_verified'] || data['is_verified']
        @artwork_filename     = data['cover_art_filename']
      end
    end
    
    # Returns a full URL to album artwork
    #
    # format - Artwork size (:small, :meduim, :large, :original)
    #
    # @return [String]
    #
    def artwork_url(format=:small)
      name = Grooveshark::ASSET_FORMATS[format] + @id.to_s
      "#{Grooveshark::ASSETS_BASE}/amazonart/#{@artwork_filename}"
    end
    
    # Returns a string representation of album
    #
    def to_s
      [@album_id, @name].join(' - ')
    end
    
    # Returns a hash formatted for API usage
    # 
    def to_hash
      {
        'albumID'          => @id,
        'albumNameID'      => @name_id,
        'artistID'         => @artist_id,
        'year'             => @year,
        'coverArtFilename' => @artwork_filename,
        'artistName'       => @artist_name
      }
    end
    
    # Returns (and if possible stores) the album songs
    #
    # @return [Array][Grooveshark::Songs]
    #
    def songs
      @songs ||= @client.get_album_songs(self)
    end
  end
end