require 'json'
require 'webrick'

module Phase9
  class Flash
    def initialize(req)
      flash_cookie = req.cookies.find do |cook|
        cook.name == '_rails_lite_app_flash'
      end

      @now = flash_cookie ? JSON.parse(flash_cookie.value) : {}
      @future = {}
    end

    def now
      @now
    end

    def [](key)
      @now[key]
    end

    def []=(key, val)
      @now[key]    = val
      @future[key] = val
    end

    def store_flash(res)
      res.cookies << WEBrick::Cookie.new(
                       '_rails_lite_app_flash',
                       @future.to_json
                     )
    end

  end
end
