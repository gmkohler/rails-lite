module Phase10
  class BaseController < Phase9::BaseController

    def initialize(req, res, route_params = {})
      super(req, res, route_params)
      find_auth_token
    end

    def reset_auth_token!
      @auth_token = SecureRandom.urlsafe_base64
      auth_token
    end

    def find_auth_token(req)
      req.cookies.find {|cook| cook.name == "_rails_lite_auth" }.value
    end

    def auth_token
      @auth_token ||= SecureRandom.urlsafe_base64
    end

    def load_auth_token(res)
      res.cookies << WEBrick::Cookie.new("_rails_lite_auth", auth_token)
    end

    def valid_auth_token?(req)
      find_auth_token(req) == @auth_token
    end
    
    def render
    end

    def redirect_to
    end


end
