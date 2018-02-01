# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
WINDOWS = (java.lang.System.getProperties['os.name'] =~ /win/i)
require './lib/logging/logging'
Rails.application.initialize!
original_logger = Rails.logger
$log_rails.define_singleton_method(:method_missing) do |symbol, args|
  $log_rails.debug{"An attempt to invoke the method #{symbol} was made on the rails logger with arguments #{args}, delegating to the original"}
  original_logger.send(symbol, args)
end
Rails.logger = $log_rails