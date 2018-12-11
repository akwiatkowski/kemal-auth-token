# kemal-auth-token

Gives the `current_user` to `kemal`.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  kemal-auth-token:
    github: akwiatkowski/kemal-auth-token
```


## Usage

### Initializer

First, you need to initialize middleware.

```crystal
auth_token_mw = Kemal::AuthToken.new
```

### Sign in

You must provide a way to sign user in. It is your choice how would you like
to do it (fetch from DB, have predefined, ...).

You must return `UserHash` it is alias of `Hash(String, (String | Int32 | Nil | Bool))`.

You can use login, id, whatever instead of an `email`.

```crystal
auth_token_mw.sign_in do |email, password|
  User.sign_in(email, password)
end
```

There is path to sign in, which you can change if you want.

```crystal
auth_token_mw.path = "/sign_in" # default value
```

If you want sign in just execute POST request:

```crystal
http = HTTP::Client.new("localhost", Kemal.config.port)
result = http.post_form("/sign_in", {"email" => "email@email.org", "password" => "password" })
json = JSON.parse(result.body)
```

Which return

```json
{"token":"some weird characters"}
```

### Using token

Next request can utilize `token` based authentication. You must provide
it within HTTP headers.

```crystal
headers = HTTP::Headers.new
headers["X-Token"] = "some weird characters"
http = HTTP::Client.new("localhost", Kemal.config.port)
result = http.exec("GET", "/path", headers)
```

### Get current user

`Kemal` needs a way how to get user information from JWT token. You must
tell how it should do.

```crystal
auth_token_mw.load_user do |jwt_payload|
  User.load_user(jwt_payload)
end
```

Keep in mind that `jwt_payload` is `Hash(String, JSON::Type)`.

You need to provide way to get user information from object (`UserHash`) stored in
JWT token here. That information should be presented also as `UserHash`.

Later you can access current user information within `Kemal` code as below:

```crystal
get "/current_user" do |env|
  env.current_user.to_json
end
```

### Final note

Please read `spec` file :)

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/akwiatkowski/kemal-auth-token/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
- [dscottboggs](https://github.com/dscottboggs) D. Scott Boggs - contributor
