module Lookbook
  class ApplicationController < ActionController::Base
    content_security_policy(false) if respond_to?(:content_security_policy)

    protect_from_forgery with: :exception

    helper Lookbook::ClassNamesHelper if Engine.runtime_context.rails_older_than?("6.1.0")
    helper Lookbook::ApplicationHelper
    helper Lookbook::UiElementsHelper

    before_action :generate_theme_overrides
    before_action :assign_instance_vars

    def self.controller_path
      "lookbook"
    end

    def index
      landing = Engine.pages.find(&:landing?) || Engine.pages.first
      if landing.present?
        redirect_to lookbook_page_path(landing.lookup_path)
      else
        render "lookbook/index"
      end
    end

    protected

    def generate_theme_overrides
      @theme_overrides ||= Engine.theme.to_css
    end

    def assign_instance_vars
      @previews = Engine.previews
      @pages = Engine.pages
      @theme = Engine.theme
      @config = Lookbook.config
      @engine = Lookbook.engine
      @embed = !!params[:lookbook_embed]
    end

    def render_in_layout(path, layout: nil, **locals)
      @error = locals[:error]
      render path, layout: layout.presence || (params[:lookbook_embed] ? "lookbook/basic" : "lookbook/application"), locals: locals
    end

    def prettify_error(exception)
      error_params = {}
      if exception.is_a?(ViewComponent::PreviewTemplateError)
        error_params = {
          file_path: @preview&.file_path,
          line_number: 0,
          source_code: @target&.source
        }
      end
      Lookbook::Error.new(exception, **error_params)
    end
  end
end
