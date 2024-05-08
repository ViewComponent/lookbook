module Lookbook
  class PageEntity < Entity
    include EntityTreeNode

    attr_writer :lookup_path, :url_path, :frontmatter, :content

    def initialize(file_path = nil, file_contents = nil, options: {}, default_priority: nil)
      @file_path = file_path
      @file_contents = file_contents
      @base_directories = Pages.page_paths
      @options = options.to_h
      @default_priority = default_priority
    end

    def id
      @id ||= Utils.id(frontmatter.fetch(:id, lookup_path))
    end

    def name
      @name ||= Utils.name(File.basename(lookup_path))
    end

    def label
      frontmatter.fetch(:label, super)
    end

    def title
      frontmatter.fetch(:title, label)
    end

    def data
      DataObject.new(frontmatter.fetch(:data, {}))
    end

    def hidden?
      frontmatter.fetch(:hidden, super)
    end

    def landing?
      frontmatter.fetch(:landing, false)
    end

    def header?
      frontmatter.fetch(:header, true)
    end

    def footer?
      frontmatter.fetch(:footer, true)
    end

    def content
      @content ||= parsed_content[:content]
      @content.strip_heredoc.strip.html_safe
    end

    def url_param
      lookup_path
    end

    def url_path
      @url_path ||= (page_path(self) unless virtual?)
    end

    def lookup_path
      @lookup_path ||= PageEntity.to_lookup_path(relative_file_path)
    end

    def frontmatter
      @frontmatter ||= DataObject.new(
        Lookbook.config.page_frontmatter_defaults
          .deep_merge(@options)
          .deep_merge(parsed_content[:frontmatter])
      )
    end

    def file_path
      Pathname(@file_path) if @file_path
    end

    def relative_file_path
      file_path.relative_path_from(base_directory)
    end

    def parent
      Pages.directories.find { _1.lookup_path == parent_lookup_path } unless virtual?
    end

    def next
      Pages.tree.next(self) unless virtual?
    end

    def previous
      Pages.tree.previous(self) unless virtual?
    end

    def priority
      @priority = begin
        pos = PriorityPrefixParser.call(file_name).first || frontmatter.fetch(:priority, 0)
        pos.to_i
      end
    end

    def virtual? = file_path.blank?

    class << self
      def to_lookup_path(page_path)
        path = page_path.to_s.downcase

        directory_path = File.dirname(path)
        directory_path = nil if directory_path.start_with?(".")

        file_name = File.basename(path).split(".").first

        segments = [*directory_path&.split("/"), file_name].compact
        segments.map! do |segment|
          PriorityPrefixParser.call(segment).last.tr("-", "_")
        end

        Utils.to_path(segments)
      end

      def virtual(lookup_path, content = nil, url_path: nil, **kwargs)
        page = new(nil, content, **kwargs)
        page.lookup_path = lookup_path
        page.url_path = url_path
        page
      end
    end

    protected

    def parsed_content
      @parsed_content ||= begin
        frontmatter, content = FrontmatterExtractor.call(@file_contents)
        {frontmatter: frontmatter, content: content}
      end
    end

    def file_name(strip_ext = false)
      basename = file_path.basename
      (strip_ext ? basename.to_s.split(".").first : basename).to_s
    end

    def base_directory
      @base_directory ||= begin
        directories = Array(@base_directories).map(&:to_s).sort_by { |path| path.split("/").size }.reverse
        directories.find { |dir| file_path.to_s.start_with?(dir) }
      end
    end

    # def file_contents
    #   @file_contents ||= @default_content || (virtual? ? "" : File.read(file_path))
    # end
  end
end
