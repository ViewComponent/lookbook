module Lookbook
  class PreviewGroup < Entity
    include Navigable

    attr_reader :examples, :preview

    def initialize(name, examples, preview)
      @name = Utils.name(name)
      @examples = PreviewExampleCollection.new(examples)
      @preview = preview
      @lookup_path = "#{parent.lookup_path}/#{@name}"
    end

    def display_options
      merged = {}
      examples.to_a.reverse.map do |example|
        merged.merge!(example.display_options)
      end
      merged
    end

    def components
      @_components ||= ComponentCollection.new(examples.flat_map(&:components).uniq(&:path))
    end

    def search_terms
      [parent.label, label]
    end

    def tags(tag_name = nil)
      examples.flat_map { |example| example.tags(tag_name) }
    end

    def tag(tag_name = nil)
      tags(tag_name).first
    end

    def url_path
      lookbook_inspect_path(path)
    end

    def preview_path
      lookbook_preview_path(path)
    end

    def type
      :group
    end

    alias_method :parent, :preview
  end
end
