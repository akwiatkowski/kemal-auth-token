require "kemal"
require "secure_random"
require "jwt"
require "json"

# Signed user is stored as a Hash
alias UserHash = Hash(String, (String | Int32 | Nil | Bool))

class Kemal::AuthToken < HTTP::Handler
  def initialize(
    @secret_key = SecureRandom.hex,
    @algorithm = "HS256",
    @path = "/sign_in",
    &@sign_in : String, String -> UserHash)
  end
  # &@load_user : String -> UserHash)

  getter :secret_key, :algorithm

  def call(context)
    # sign_in
    if context.request.path == @path
      if context.params.body["email"]? && context.params.body["password"]?
        uh = @sign_in.call(context.params.body["email"], context.params.body["password"])
        if uh["id"]?
          # that means it's ok
          token = JWT.encode(uh, @secret_key, @algorithm)
          context.response << {token: token}.to_json
          return context
        end
      end
    end

    # auth
    if context.request.headers["X-Token"]?
      token = context.request.headers["X-Token"]
      payload, header = JWT.decode(token, @secret_key, @algorithm)
      puts payload.class
      puts header.class
      puts payload.inspect, header.inspect
    end
    call_next context
  end


end
