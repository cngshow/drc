class ApplicationController < ActionController::Base
  include RouteHelper, ServletSupport
  protect_from_forgery with: :exception
  rescue_from Exception, java.lang.Throwable, :with => :internal_error
  before_action :setup_gon

  def internal_error(exception)
    $log.error(LEX('An uncaught exception!', exception))
    raise exception
  end

  def setup_gon
    gon.routes = setup_routes
    gon.packs = packed_assets
    gon.websocket_endpoint_path = WEBSOCKET_ENDPOINT
    gon.websocket_endpoint_url = get_websocket_url
    @@channels ||= Hash[WebSocketSupport::Channels.constants.zip( WebSocketSupport::Channels.constants.map {|c| WebSocketSupport::Channels.const_get(c)})]
    gon.websocket_channel = @@channels
  end
end
