module Grooveshark
  module Request
    API_BASE        = 'grooveshark.com'
    UUID            = 'C01D17E7-1B0C-4737-A48F-82E4F8BD306B'
    CLIENT          = 'htmlshark'
    CLIENT_REV      = '20120312'
    COUNTRY         = {"DMA"=>0,"CC1"=>0,"IPR"=>0,"CC2"=>0,"CC3"=>2305843009213694000,"ID"=>190,"CC4"=>0}
    #{"CC2" => "0", "IPR" => "353", "CC4" => "1073741824", "CC3" => "0", "CC1" => "0", "ID" => "223"}
    TOKEN_TTL       = 120 # 2 minutes
    
    # Client overrides for different methods
    METHOD_CLIENTS = {
      'getStreamKeyFromSongIDEx' => 'jsqueue' 
    }
    
    # Perform API request
    def request(method, params={}, secure=false)
      refresh_token if @comm_token
      
      agent = METHOD_CLIENTS.key?(method) ? METHOD_CLIENTS[method] : CLIENT
      url = "#{secure ? 'https' : 'http'}://#{API_BASE}/more.php?#{method}"
      body = {
        'header' => {
          'session' => @session,
          'uuid' => UUID,
          'client' => agent,
          'clientRevision' => CLIENT_REV,
          'country' => COUNTRY
        },
        'method' => method,
        'parameters' => params
      }
      body['header']['token'] = create_token(method) if @comm_token
      
      begin
        pp "BODY::: for URL: #{url}"
        pp body
        data = RestClient.post(
          url, body.to_json,
          :content_type => :json,
          :accept => :json,
          :cookie => "PHPSESSID=#{@session}"
        )
        pp "Response :::: "
        pp data
      rescue Exception => ex
        raise GeneralError    # Need define error handling
      end
      
      data = JSON.parse(data)
      data = data.normalize if data.kind_of?(Hash)
      
      if data.key?('fault')
        raise ApiError.new(data['fault'])
      else
        data['result']
      end
    end
    
    # Refresh communications token on ttl
    def refresh_token
      get_comm_token if Time.now.to_i - @comm_token_ttl > TOKEN_TTL
    end
  end
end