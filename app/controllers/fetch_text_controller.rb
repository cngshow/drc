class FetchTextController < ApplicationController

  def fetch_text
    vals = []
    vals << 'this is the first one'
    vals << 'this is another one'
    vals << 'this is one more'

    (1..8).each do
      vals << SecureRandom.base64
    end
    WebSocketSupport.broadcast_all(message: "Hi guys, the time is #{Time.now}")
    WebSocketSupport.broadcast(channel: WebSocketSupport::Channels::ROOT_BEER, message: "Root beer time!! #{Time.now}")
    render json: {text: "#{params[:btn]} #{vals.sample}"}
  end
end
