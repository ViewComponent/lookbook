module Lookbook
  module AppHelper
    # Components

    def lb_tag(*args, **kwargs, &block)
      render Lookbook::UI::Tag.new(*args, **kwargs), &block
    end

    def lb_breadcrumbs(*args, **kwargs, &block)
      render Lookbook::UI::Breadcrumbs.new(items: args.flatten, **kwargs), &block
    end

    def lb_button(**kwargs, &block)
      render Lookbook::UI::Button.new(**kwargs), &block
    end

    def lb_button_group(**kwargs, &block)
      render Lookbook::UI::ButtonGroup.new(**kwargs), &block
    end

    def lb_code(source = nil, lang: nil, **kwargs, &block)
      render Lookbook::UI::Code.new(source: source, lang: lang, **kwargs), &block
    end

    def lb_icon(name = nil, **kwargs)
      render Lookbook::UI::Icon.new(name: name, **kwargs)
    end

    def lb_table(**kwargs, &block)
      render Lookbook::UI::Table.new(**kwargs), &block
    end

    def lb_page(entity = nil, **kwargs, &block)
      render Lookbook::UI::Page.new(entity: entity, **kwargs), &block
    end

    def lb_pane(id = nil, **kwargs, &block)
      render Lookbook::UI::Pane.new(id: id, **kwargs), &block
    end

    def lb_pane_group(id = nil, tag: :div, **kwargs, &block)
      render Lookbook::UI::PaneGroup.new(id: id, tag_name: tag, **kwargs), &block
    end

    def lb_prose(**kwargs, &block)
      render Lookbook::UI::Prose.new(**kwargs), &block
    end

    def lb_toolbar_button(icon = nil, **kwargs, &block)
      render Lookbook::UI::ToolbarButton.new(icon: icon, **kwargs), &block
    end

    def lb_toolbar_button_group(**kwargs, &block)
      render Lookbook::UI::ToolbarButtonGroup.new(**kwargs), &block
    end

    def lb_viewport(src, **kwargs)
      render Lookbook::UI::Viewport.new(src: src, **kwargs)
    end

    # Paths

    def lookbook_page_path(page, **kwargs)
      lookbook.page_path(page, **kwargs)
    end

    def lookbook_preview_path(preview, target = nil, **kwargs)
      target.nil? ? lookbook.preview_page_path(preview, **kwargs) : lookbook.inspect_target_path(preview, target, **kwargs)
    end

    # Utilities

    def markdown(...)
      Markdown.render(...)
    end

    def code_comment(...)
      Languages.comment(...)
    end

    def checksum(input)
      Lookbook::Utils.hash(input)
    end
  end
end
