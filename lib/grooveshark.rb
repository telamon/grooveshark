require 'grooveshark/utils'
require 'grooveshark/errors'
require 'grooveshark/connection'
require 'grooveshark/request'
require 'grooveshark/client'
require 'grooveshark/user'
require 'grooveshark/playlist'
require 'grooveshark/song'
require 'grooveshark/artist'
require "grooveshark/album"

module Grooveshark
  class << self
    # Shortcut to Grooveshark::Client.new
    #
    # session - Session ID (optional)
    #
    def new(session=nil)
      Grooveshark::Client.new(session)
    end
  end
end