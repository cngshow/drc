$CLASSPATH << './lib/oracle/ojdbc8.jar'
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
require './lib/props/prop_loader' #Grant visibility to $PROPS at this level.

Bundler.require(*Rails.groups)

module Vso
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
