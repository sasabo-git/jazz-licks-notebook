require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module JazzLicksNotebook
  class Application < Rails::Application
    config.load_defaults 6.0
    config.generators.template_engine = :slim
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
  end
end
