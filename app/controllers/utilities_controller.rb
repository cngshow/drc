class UtilitiesController < ApplicationController
  include WebSocketSupport

  def ajax_show_headers
    headers = []

    request.headers.each do |elem|
      row = {header_key: elem.first.to_s, header_value: elem.last.to_s}
      headers << row
    end
    render :json => headers
  end

  def ajax_form_submission
    g = params
    render :json => params
  end

  def ajax_websocket_test
    msg = params['post_msg']
    ws_setup = JSON.indifferent_parse(request.headers['HTTP_WS_SETUP'])
    channel = ws_setup[WebSocketSetup::BROADCAST_CHANNEL_SETUP]
    server_uuid  = ws_setup[WebSocketSetup::SERVER_UUID]
    client_uuid  = ws_setup[WebSocketSetup::CLIENT_UUID]
    WebSocketSupport.broadcast(channel: channel, message: "Post message: #{msg} at #{Time.now}")
    WebsocketTestJob.set(wait_until: 5.seconds.from_now).perform_later(server_uuid, client_uuid)
    render :json => params
  end
end
