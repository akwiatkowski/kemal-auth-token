require "./spec_helper"

describe Kemal::AuthToken do
  it "works" do

    Kemal.config.add_handler Kemal::AuthToken.new
    Kemal.config.port = 8002

    get "/" do
      "This won't render without correct username and password."
    end

    spawn do
      Kemal.run
    end

    # wait for Kemal is ready
    while Kemal.config.server.nil?
      sleep 0.1
    end

    headers = HTTP::Headers.new
    headers["X-Token"] = "token"

    http = HTTP::Client.new("localhost", Kemal.config.port)
    http.exec("GET", "/", headers)

  end
end
