module Lookbook
  class CodeInspector
    include Utils

    attr_reader :code_object
    delegate :groups, :source, to: :@code_object, allow_nil: true

    def initialize(taggable_object_path)
      @code_object = Lookbook::Engine.parser.get_code_object(taggable_object_path)
    end

    def hidden?
      if code_object&.tag(:hidden)
        code_object.tag(:hidden).text.strip != "false"
      end
    end

    def id
      if code_object&.tag(:id)&.text&.present?
        generate_id(code_object&.tag(:id)&.text)
      end
    end

    def design
      extract_params_from_tag(:design)
    end

    def label
      code_object&.tag(:label)&.text
    end

    def notes
      if code_object&.docstring
        code_object.docstring.to_s.strip
      end
    end

    def group
      code_object&.group
    end

    def position
      code_object&.tag(:position)&.text&.to_i || 10000
    end

    def display_params
      extract_params_from_tag(:display)
    end

    def parameter_defaults
      code_object&.parameters&.map { |str| Params.parse_method_param_str(str) }&.compact&.to_h
    end

    def params
      code_object&.tags("param")&.map do |param|
        Lookbook::Params.build_param(param, parameter_defaults[param.name])
      end
    end

    def methods
      code_object&.meths
    end

    private

    def extract_params_from_tag(tag)
      params = {}.with_indifferent_access
      if code_object&.tags(tag).present?
        code_object.tags(tag).each do |tag|
          parts = tag.text.strip.match(/^([^\s]*)\s?(.*)$/)
          if parts.present?
            begin
              params[parts[1]] = YAML.safe_load(parts[2] || "~")
            rescue SyntaxError => err
              Lookbook.logger.error("\n👀 [Lookbook] Invalid JSON in @#{tag} tag.\n👀 [Lookbook] (#{err})\n")
            end
          end
        end
      end
      params
    end
  end
end
