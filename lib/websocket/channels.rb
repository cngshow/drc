module WebSocketSupport

  module WebSocketSetup
    BROADCAST_CHANNEL_SETUP = :broadcast_channel_setup
    SERVER_UUID = :uuid
    CLIENT_UUID = :client_uuid
  end

  #currently test needs at least two channels (one channel to not get messages)
  module Channels
    ROOT_BEER = :root_beer
    COKE = :coke
    UNUSED = :unused
  end

end
