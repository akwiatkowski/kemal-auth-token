require "http/server"
require "json"

class HTTP::Server
  class Context
    @current_user = UserHash.new

    property :current_user
  end
end
