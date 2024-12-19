require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Miele
  class Application < Rails::Application
    config.load_defaults 5.2
    I18n.config.enforce_available_locales = (Rails.env.test? ? false : true)
    config.i18n.available_locales = ["es","en","uf"]
    config.i18n.default_locale = "es"

    config.time_zone = 'Santiago'
    config.active_record.belongs_to_required_by_default = false
    

     config.action_mailer.delivery_method = :smtp

    # if Rails.env.development?
    #   File.open('config/version', 'w') do |file|
    #     file.write `git describe --abbrev=0 --tags` 
    #   end
    # end
    config.version = File.read('config/version')

    config.exceptions_app = self.routes 

    config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end