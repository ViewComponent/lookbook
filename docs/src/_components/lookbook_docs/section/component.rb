module LookbookDocs
  class Section::Component < Base
    renders_one :title, ->(text, **opts) do
      toc.push({id: id, label: text})
      render(Heading::Component.new(id: id, **opts)) { text }
    end

    renders_many :blocks, types: {
      prose: Prose::Component,
      html: ->(&block) { capture(&block).html_safe },
      lede: Lede::Component,
      method_list: MethodList::Component,
      options_list: OptionsList::Component,
      data_list: DataList::Component,
      button: ButtonBlock::Component,
      screenshot: ->(src, caption = nil, **kwargs) do
        Screenshot::Component.new(src: src, caption: caption, **kwargs)
      end,

      subheading: ->(text, id: nil, level: 3, display_level: nil, **opts) do
        toc.push({id: id, label: text, level: level}) if id
        render(Heading::Component.new(id: id, level: display_level || level, **opts)) { text }
      end,

      note: ->(theme = :info, **opts) do
        Note::Component.new(theme: theme, **opts)
      end,

      api_module_methods: ->(module_name, **opts) do
        data = api_methods_data(module_name)
        if data
          render MethodList::Component.new do |list|
            data.each do |method|
              list.with_item_api_method(**method, scope: "global")
            end
          end
        end
      end,

      api_method: ->(module_name, method_name, **opts) do
        data = api_method_data(module_name, method_name)
        render ApiMethod::Component.new(**data, **opts) if data
      end,

      api_method_options_list: ->(module_name, method_name, arg: :opts, **opts) do
        data = api_method_data(module_name, method_name)
        if data
          options = data[:tags].filter { |tag| tag[:tag_name].to_s == "option" && tag[:pair].to_s == arg.to_s }
          render OptionsList::Component.new(options: options)
        end
      end
    }

    attr_reader :toc, :id

    def initialize(toc:, title: nil, id: nil, overview: false, **attrs)
      @toc = toc
      @overview = overview
      @id = id || (overview? ? "overview" : nil)
      @title = title || (overview? ? "Overview" : nil)
      @attrs = attrs
    end

    def overview?
      @overview == true
    end

    def before_render
      if @title
        with_title(@title, hidden: overview?)
      end
      with_block_prose.with_content(content) if content.present?
    rescue
    end
  end
end
