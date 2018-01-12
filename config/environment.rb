# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
WINDOWS = (java.lang.System.getProperties['os.name'] =~ /win/i)
require './lib/logging/logging'
CATALINA_HOME = java.lang.System.properties['catalina.home']
Rails.application.initialize!
