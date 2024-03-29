require_relative "../../../lib/lookbook/version"

class Builders::Site < SiteBuilder
  def build
    helper :lookbook_version do
      Lookbook::VERSION
    end

    helper :url_segment do |resource, pos = 1|
      resource.relative_url.split("/")[pos] if resource.present?
    end

    helper :guide_url, helpers_scope: true do |id|
      page_url(:guide, id)
    end

    helper :extend_url, helpers_scope: true do |id|
      page_url(:extend, id)
    end

    helper :api_url, helpers_scope: true do |id|
      page_url(:api, id)
    end

    helper :page_url, helpers_scope: true do |collection_name, id|
      page = find_by_id(collection_name, id)
      page ? page.relative_url : "#"
    end

    helper :find_by_id do |collection_name, id|
      collection = site.collections[collection_name]
      collection&.resources&.find do |resource|
        normalize_id(resource.data&.id) == normalize_id(id)
      end
    end

    helper :dom_id do |*args|
      normalize_id(args.join("-"), kebab: true) if args.present?
    end

    helper :links, helpers_scope: true do
      site.data.links
    end

    helper :section_collections, helpers_scope: true do
      site.collections.select { _2.metadata[:section] }
    end

    helper :sections, helpers_scope: true do
      section_collections.map do |label, col|
        resource_ids = site.data["#{label}_nav"].groups.flat_map(&:items)
        index = col.resources.find { _1.data.id == resource_ids.first }
        {
          url: index.relative_url,
          label: col.metadata.label || col.metadata.title,
          active: (view.resource.collection.label == label)
        }
      end
    end

    helper :current_group, helpers_scope: true do
      collection = view.resource.collection
      if collection
        site.data["#{collection.label}_nav"].groups.find do |group|
          group[:items].include?(view.resource.data.id)
        end
      end
    end

    helper :collection_resources, helpers_scope: true do |collection_name|
      collection = site.collections[collection_name]
      resource_ids = site.data["#{collection_name}_nav"].groups.flat_map(&:items)
      resource_ids.map do |id|
        collection.resources.find { _1.data.id == id }
      end
    end

    helper :find_group_for_page, helpers_scope: true do |collection_name, id|
      groups = site.data["#{collection_name}_nav"].groups
      groups.find { |g| g.items.find { _1 == id } }
    end

    helper :find_page_group_label, helpers_scope: true do |page|
      return unless page
      group = find_group_for_page(page.collection.label, page.data.id)
      group["label"] if group
    end

    helper :find_prev_page, helpers_scope: true do
      resources = collection_resources(view.resource.collection.label) || []
      index = resources.find_index { |res| res.data.id == view.resource.data.id }
      resources[index - 1] if index.present? && index > 0
    end

    helper :find_next_page, helpers_scope: true do
      resources = collection_resources(view.resource.collection.label) || []
      index = resources.find_index { |res| res.data.id == view.resource.data.id }
      resources[index + 1] if index.present? && index < resources.size - 1
    end

    helper :markdown do |input = nil, &block|
      content = Bridgetown::Utils.reindent_for_markdown(
        block.nil? ? input.to_s : view.capture(&block)
      )
      converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
      converter.convert(content).strip.html_safe
    end

    helper :add_toc_entry, helpers_scope: true do |entry|
      view.resource.data.toc.push(entry)
    end

    helper :api_module_url, helpers_scope: true do |klass|
      site_context = site || view.site
      collection = site_context&.collections&.api
      if collection
        subject = klass.underscore
        resource = collection.resources.find { |r| r.data.subject == subject }
        resource&.relative_url
      end
    end

    helper :api_module_data, helpers_scope: true do |klass|
      klass = klass.to_s.downcase.underscore.to_sym
      set = nil
      site.data.api.each do |key, data|
        if data[klass].present?
          set = data[klass]
          break
        end
      end
      set&.symbolize_keys
    end

    helper :api_method_data, helpers_scope: true do |klass, method_name|
      method_name = method_name.to_s
      klass_data = api_module_data(klass)
      klass_data[:methods]&.find { |m| m[:name]&.to_s == method_name }&.symbolize_keys
    end

    helper :api_methods_data, helpers_scope: true do |klass|
      klass_data = api_module_data(klass)
      klass_data[:methods]&.map { |m| m.symbolize_keys }
    end
  end

  private

  def normalize_id(id, kebab: false)
    id = id.to_s.dasherize
    kebab ? id.tr("_", "-") : id.tr("-", "_")
  end
end
