require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module IQuiz
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Brasilia"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]
    config.i18n.fallbacks = [:en]
  end
end
