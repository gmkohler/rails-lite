require_relative './controller_base'
require 'byebug'
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern # URI path; regex with labeled captures
    @http_method = http_method # "GET", "POST", "PUT", "DELETE"
    @controller_class = controller_class # which controller?
    @action_name = action_name # method on controller
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    (pattern === req.path && http_method == req.request_method.downcase.to_sym)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    matched = pattern.match(req.path)
    route_params = Hash[matched.names.zip(matched.captures)]

    res = controller_class.new(req, res, route_params)
            .invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
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

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      @routes << Route.new(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.select { |route| route.matches?(req) }.first
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matching_route = match(req)
    # verified = valid_auth_token?(req)
    # reset_auth_token!

    if matching_route
      unless (req.request_method == "GET" || verified)
        res.status = "H4XX0R ALERT"
        return res
      else
        load_auth_token(res)
        matching_route.run(req, res)
      end
    else
      res.status = 404
      res
    end

  end
end
