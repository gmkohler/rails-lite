require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './params'
require_relative './flash'
require_relative './router'

class ControllerBase
  attr_reader :req, :res, :params, :flash

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def already_built_response?
    @already_built_response
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def invoke_action(name)
    send(name)
    render name unless already_built_response?
  end

  # Set the response status code and header
  def redirect_to(url)
    unless already_built_response?
      res["Location"] = url
      res.status = 302
      session.store_session(res)
      flash.store_flash(res)
      load_auth_token(res)
      @already_built_response = true
    else
      raise "Already rendered response"
    end
  end

  # Populate the response with content.
  # Raise an error if the developer tries to double render.
  def render(template_name)
    b = binding
    f = File.read(
      "../views/#{self.class.name.underscore}/#{template_name}.html.erb"
    )
    render_content(ERB.new(f).result(b), "text/html")
  end

  def render_content(content, content_type)
    unless already_built_response?
      res.content_type = content_type
      res.body = content
      session.store_session(res)
      flash.store_flash(res)
      @already_built_response = true
    else
      raise "Already rendered response"
    end
  end




end
