require 'logger'
require 'faraday_middleware'

module Grooveshark
  def self.gen_uuid
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".gsub /[xy]/ do |a|
            b = (rand * 16).to_i
            c = a == "x" ? b : b & 3 | 8
            c.to_s(16).upcase
        end
  end
  WEBSITE_URL     = 'https://grooveshark.com'
  API_BASE        = 'grooveshark.com'
  ASSETS_BASE     = 'https://beta.grooveshark.com/static'
  UUID            = self.gen_uuid
  CLIENT          = 'htmlshark'
  CLIENT_REV      = '20120312'
  COUNTRY         = {"CC2" => "0", "IPR" => "353", "CC4" => "1073741824", "CC3" => "0", "CC1" => "0", "ID" => "223"}
  SALT            = 'someThumbsUp'
  TOKEN_TTL       = 120 # 2 minutes
  
  # User agent overrides for different methods
  METHOD_CLIENTS = {
    'getStreamKeyFromSongIDEx' => 'jsqueue' 
  }
    
  # Salt overrides for different methods
  METHOD_SALTS = { 
    'getStreamKeyFromSongIDEx' => 'someThumbsUp'
  }
  
  # Album covers and user pictures size prefixes
  ASSET_FORMATS = {
    :small    => 's',
    :medium   => 'm',
    :large    => 'l',
    :original => ''
  }
  
  @@debug = true
  
  # Returns true if request logger is enabled
  #
  def self.log_requests
    @@debug
  end
  
  # Enable request logger (STDOUT)
  #
  def self.log_requests= (value)
    @@debug = value ? true : false
  end
  
  module Connection
    protected
    require 'json'
    # Creates a new faraday connection
    #
    # https - Use secure connection (default: false)
    #
    # @return [Faraday::Connection]
    #
    def connection(https=false)
      base_url = "https://" #https ? 'https://' : 'http://'
      base_url << API_BASE
      
      Faraday.new(base_url) do |c|
        c.use(Faraday::Response::Logger)     if Grooveshark.log_requests
        c.use(Faraday::Request::UrlEncoded)
        c.use(Faraday::Response::ParseJson)
        c.adapter(Faraday.default_adapter)
      end
    end
      
    # Request a new session token
    #
    # @return [String]
    #
    def request_session_token
      Digest::SHA1.hexdigest(rand.to_s)[0..32] 
      #resp = Faraday.get(WEBSITE_URL)
      #resp.headers[:set_cookie].to_s.scan(/PHPSESSID=([a-z\d]{32});/i).flatten.first 
    end
  end
end
