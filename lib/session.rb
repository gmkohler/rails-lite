require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    app_cookie = req.cookies.find{ |cook| cook.name == '_rails_lite_app' }
    @data = app_cookie ? JSON.parse(app_cookie.value) : {}
  end

  def [](key)
    @data[key]
  end

  def []=(key, val)
    @data[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @data.to_json)
  end
end
