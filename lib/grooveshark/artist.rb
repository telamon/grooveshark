module Grooveshark
  class Artist
    attr_reader :id, :name, :songs
    
    # Initialize a new Grooveshark::Artist object
    #
    # client - Grooveshark::Client instance
    # data   - Hash containing artist information
    #
    def initialize(client, data={})
      unless client.kind_of?(Grooveshark::Client)
        raise ArgumentError, "Grooveshark::Client required!"
      end
      
      @client = client
      @id     = Integer(data['artist_id'] || data['id'])
      @name   = data['artist_name'] || data['name']
    end
    
    # Returns a hash formatted for API usage
    # 
    def to_hash
      {
        'artistID'    => @id,
        'Name'        => @name
      }
    end
    
    # Returns a collection of artist's songs
    #
    def songs
      @songs ||= @client.get_songs_by_artist(self)
    end
  end
end
