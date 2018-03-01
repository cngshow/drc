require './lib/util/helpers'
require './lib/websocket/websocket'

WEBSOCKET_ENDPOINT = JWebSocketSupport::END_POINT

begin
  ActiveRecord::Base.logger = $log_rails
  ActiveRecord::Migrator.migrate 'db/migrate'
rescue => ex
  $log.warn("Migration failed. #{ex.message}")
ensure
  #ActiveRecord::Base.logger = nil
end