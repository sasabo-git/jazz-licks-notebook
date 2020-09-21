# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module JazzLicksNotebook
  class Application < Rails::Application
    config.load_defaults 6.0
    config.generators.template_engine = :slim
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.i18n.default_locale = :ja
  end
end
