require "kemal"
require "secure_random"
require "jwt"

# require "./kemal-auth-token/*"

class Kemal::AuthToken < HTTP::Handler
  def call(context)
    puts context.request.headers.inspect
    call_next context
  end
end
