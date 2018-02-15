require 'test_helper'

class WebsocketsTest < ActionDispatch::IntegrationTest
  include WebSocketSupport, WebSocketSupport::WebSocketSetup


  setup do
    WEBSOCKET_MSG_RCVD.clear
    @ws = JWebSocketSupport.new
    @ws.start(SessionMock.new)
    initial_data = {}
    @channel = Channels.const_get(Channels.constants.first)
    initial_data[BROADCAST_CHANNEL_SETUP] = @channel
    @server_uuid = SecureRandom.uuid
    @client_uuid = SecureRandom.uuid
    initial_data[SERVER_UUID] = @server_uuid
    initial_data[CLIENT_UUID] = @client_uuid
    @ws.incoming(initial_data.to_json)
  end

  test 'websocket_can_chat' do
    message = "Hi there!"
    WEBSOCKET_MSG_RCVD.message_received do |msg|
      assert(message.eql? message)
    end
    @ws.incoming(message)
  end

  test 'websocket_can_die' do
    @ws.end
    assert(!@ws.isPresent)
  end

  test 'can_lookup_ws' do
    assert (WebSocketSupport.websockets_by_client[[@server_uuid, @client_uuid]]&.first.eql? @ws)
  end

  test 'can_channel_lookup_ws' do
    assert (WebSocketSupport.websockets_by_channel[@channel].include? @ws)
  end

  test 'websocket_can_inform_death' do
    @ws.end
    assert (!WebSocketSupport.websockets_by_client[[@server_uuid, @client_uuid]]&.first.eql? @ws)
    assert (!WebSocketSupport.websockets_by_channel[@channel].include? @ws)
  end

  test 'can_be_channel_chatty' do
    @no_one_is_listening = Channels.const_get(Channels.constants.last)
    WEBSOCKET_MSG_RCVD.channel_message_received(channel: WebSocketSupport::Channels::UNUSED) do |msg, chatter|
      @nothing = 'drat!'
    end
    WEBSOCKET_MSG_RCVD.channel_message_received(channel: @channel) do |msg, chatter|
      @message = msg
    end
    chat = 'Hi there!!'
    @ws.incoming(chat)
    assert(@nothing.nil?)
    assert(!@message.nil?)
    assert(@message.eql? chat)
  end

  teardown do
    JWebSocketSupport.remove(@ws)
  end
end

#may need more energy here if we ever test chatting to outside world
class SessionMock
  include javax.websocket.Session

  def method_missing(name, *args, &block)
    puts "#{name} invoked"
    nil
  end

end
