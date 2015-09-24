require_relative '../phase6/controller_base'
require_relative './flash.rb'

module Phase9
  class ControllerBase < Phase6::ControllerBase
    attr_reader :flash

    def render_content(content, content_type)
      super(content, content_type)
      flash.store_flash(res)
    end

    def redirect_to(url)
      super(url)
      flash.store_flash(res)
    end

    def flash
      @flash ||= Flash.new(req)
    end

  end
end
