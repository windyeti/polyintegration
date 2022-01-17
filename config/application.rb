require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Polyintegration
  class Application < Rails::Application

    Capybara.current_driver = :poltergeist
    # Capybara.current_driver = :selenium_chrome_headless

    config.autoload_paths += %W(#{config.root}/app)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :delayed_job

    config.time_zone = 'Moscow'
  end
end
