ENV["RAILS_ENV"] ||= "test"

require "bundler"

Bundler.require :default, :development

require "minitest/hooks"
require "minitest/reporters"
require "minitest/autorun"
require "rails/test_help"
require "capybara/cuprite"

require_relative "support/combustion"

module LookbookPathHelpers
  def scenario_preview_path(preview_class, scenario_name)
    preview_class_name = preview_class.is_a?(String) ? preview_class : preview_class.name
    preview = Lookbook::Previews.find { _1.preview_class_name == preview_class_name }
    lookbook.preview_target_path(preview, scenario_name)
  end
end

Minitest::Reporters.use!

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
end

class ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
end

class ActionDispatch::SystemTestCase
  extend Minitest::Spec::DSL
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite, using: :headless_chrome, screen_size: [1400, 1400]
end