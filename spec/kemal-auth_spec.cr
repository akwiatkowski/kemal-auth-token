require "./spec_helper"

# Let's define fake User object
# Normally you want to have access to DB

SIGNED_EMAIL = "signed@email.org"
SIGNED_PASSWORD = "hard_password"
SIGNED_ID = 3

struct User
  @id : (Nil | Int32) = nil # 1
  @name : (Nil | Int32) = nil # "Jon Boe"
  @email : (Nil | String) = nil # "email@email.org"
  @password : (Nil | String) = nil # "password"

  property :id, :name, :email, :password

  # Sign in mockup
  # Email and password are arguments
  # Hash with user information as return
  def self.sign_in(email : String, password : String) : UserHash
    h = UserHash.new

    if email == SIGNED_EMAIL && SIGNED_PASSWORD == SIGNED_PASSWORD
      h["email"] = SIGNED_EMAIL
      h["id"] = SIGNED_ID

      return h
    else
      h["error"] = true

      return h
    end
  end

  def self.load_user(user : Hash) : UserHash
    u = UserHash.new
    id = user["id"].to_s

    if id != ""
      u["id"] = id.to_i
      if u["id"] == SIGNED_ID
        u["email"] = SIGNED_EMAIL
      end
    end
    u
  end
end


describe Kemal::Auth do
  it "works" do

    # auth_token_mw = Kemal::AuthToken.new(sign_in: sign_in_proc)
    auth_token_mw = Kemal::AuthToken.new
    auth_token_mw.sign_in do |email, password|
      User.sign_in(email, password)
    end
    auth_token_mw.load_user do |user|
      User.load_user(user)
    end

    Kemal.config.add_handler(auth_token_mw)
    Kemal.config.port = 8002

    get "/current_user" do |env|
      env.current_user.to_json
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
    result = http.post_form("/sign_in", {"email" => SIGNED_EMAIL, "password" => SIGNED_PASSWORD })
    json = JSON.parse(result.body)
    token = json["token"].to_s

    headers = HTTP::Headers.new
    headers["X-Token"] = token

    # not signed request
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/current_user")
    json = JSON.parse(result.body)
    json["id"]?.should eq nil
    json["email"]?.should eq nil

    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/current_user", headers)
    json = JSON.parse(result.body)
    json["id"].should eq SIGNED_ID
    json["email"].should eq SIGNED_EMAIL

  end
end
