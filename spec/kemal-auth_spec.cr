require "./spec_helper"

# Let's define fake User object
# Normally you want to have access to DB

$SIGNED_EMAIL = "signed@email.org"
$SIGNED_PASSWORD = "hard_password"

struct User
  @id : (Nil | Int32) = 1
  @name : (String | Int32) = "Jon Boe"
  @email : (Nil | String) = "email@email.org"
  @password : (Nil | String) = "password"

  property :id, :name, :email, :password

  # Sign in mockup
  # Email and password are arguments
  # Hash with user information as return
  def self.sign_in(email : String, password : String) : UserHash
    h = UserHash.new


    if email == $SIGNED_EMAIL && $SIGNED_PASSWORD == $SIGNED_PASSWORD
      h["email"] = $SIGNED_EMAIL
      h["id"] = 1

      return h
    else
      h["error"] = true

      return h
    end
  end
end


describe Kemal::Auth do
  it "works" do

    user_id = 1

    auth_token_mw = Kemal::AuthToken.new() do |email, password|
      User.sign_in(email, password)
    end

    Kemal.config.add_handler(auth_token_mw)
    Kemal.config.port = 8002

    get "/" do |env|
      puts env.class
      "This won't render without correct username and password."
    end

    spawn do
      Kemal.run
    end

    # wait for Kemal is ready
    while Kemal.config.server.nil?
      sleep 0.01
    end

    # sign in
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.post_form("/sign_in", {"email" => $SIGNED_EMAIL, "password" => $SIGNED_PASSWORD })
    puts result.inspect


    payload = { "user_id" => user_id }
    token = JWT.encode(payload, auth_token_mw.secret_key, auth_token_mw.algorithm)

    headers = HTTP::Headers.new
    headers["X-Token"] = token

    http = HTTP::Client.new("localhost", Kemal.config.port)
    http.exec("GET", "/", headers)

  end
end
