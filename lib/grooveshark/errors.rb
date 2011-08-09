module Grooveshark
  class Error                 < StandardError ; end
  class InvalidAuthentication < Error ; end
  class ReadOnlyAccess        < Error ; end
  class GeneralError          < Error ; end
  class NotFound              < Error ; end
  
  # Generic grooveshark API error
  #
  class ApiError < Error
    attr_reader :code
  
    def initialize(fault)
      @code    = fault['code']
      @message = fault['message']
    end
  
    def to_s
      "#{@code} - #{@message}"
    end
  end
end