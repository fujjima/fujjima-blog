require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FujjimaBlog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = 'Asia/Tokyo'
    config.i18n.default_locale = :ja

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.test_framework :rspec,
        view_specs: false,
        helper_specs: false,
        controller_specs: false,
        routing_specs: false
    end
  end
end
