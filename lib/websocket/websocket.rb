require './lib/websocket/channels'
if ENV['LOAD_WEBSOCKET_JARS']
  urls = []
  jars = Dir.glob("#{Rails.root}/lib/websocket/*.jar")
  jars.each do |j|
    urls << java.io.File.new(j).toURI.toURL
  end
  urls << java.io.File.new("#{Rails.root}/lib/jars/javax.websocket-api.jar").toURI.toURL
  urls << java.io.File.new("#{Rails.root}/lib/jars/juli.jar").toURI.toURL

  urls.each do |url|
    java.lang.ClassLoader.getSystemClassLoader.addURL(url) #put it high up on the classloader chain so Tomcat finds it and instantiates with the first 'ws://...' request.
  end
end

java_import 'gov.va.rails.websocket.WebSocketSupport' do |p, c|
  'JWebSocketSupport'
end

module WebSocketSupport

  WEBSOCKET_LOCK = java.lang.Object.new

  class << self
    attr_accessor :websockets

    def validate(channel:)
      valid = WebSocketSupport::Channels.constants.map {|c| WebSocketSupport::Channels.const_get(c)}
      raise ArgumentError.new("Channel #{channel} is invalid.  Valid channels are #{valid}.") unless valid.include? channel.to_sym
    end

    def broadcast_all(message:)
      JWebSocketSupport.broadcast(message)
    end

    def broadcast(channel:, message:)
      $log.always("broadcast to #{channel} with message #{message}")
      validate(channel: channel)
      $log.always("channel #{channel} is valid. The websockets are: #{WebSocketSupport.websockets[channel]}")
      $log.always("All the websockets are: #{WebSocketSupport.websockets}")
      WEBSOCKET_LOCK.synchronized do
        invalid_sockets = []
        WebSocketSupport.websockets[channel]&.each do |socket|
          if socket.isPresent
            $log.always {"broadcasting to #{channel} on #{socket}"}
            success = JWebSocketSupport.chat(socket, message)
            $log.always {"broadcast to #{socket} was successful? #{success}"}
          else
            invalid_sockets << socket
            $log.always {"broadcast of #{message} to #{socket} failed as the socket is no longer active."}
          end
        end
        WebSocketSupport.websockets[channel] = WebSocketSupport.websockets[channel] - invalid_sockets rescue WebSocketSupport.websockets[channel] #in case we are nil we stay nil.
      end
    end
  end

  module TerminateNotifications
  end

  class WebSocketRemovedObserver
    include java.util.Observer
    include Singleton, WebSocketSupport::Channels

    def update(jobservable, websocket)
      $log.always("Attempting removal #{jobservable}, #{jobservable.java_class}, with #{websocket}")
      WEBSOCKET_LOCK.synchronized do
        WebSocketSupport.websockets.each_pair do |key, value|
          value.delete_if do |socket|
            remove = socket.eql? websocket
            $log.always {"Removal of #{websocket} occured!"}
            remove
          end
        end
      end
    end

    private
    def initialize
      JWebSocketSupport.getWebSocketRemovedNotifier.addObserver(self)
      WebSocketSupport.websockets = HashWithIndifferentAccess.new
    end
  end

  class WebSocketMessageObserver
    include java.util.Observer
    include Singleton, WebSocketSupport::Channels

    #block called for any message, channel doesn't matter
    def message_received(&block)
      if block_given?
        @on_message_blocks ||= []
        @on_message_blocks << block
      end
    end

    #block called for any message, channel doesn't matter
    def channel_message_received(channel:, &block)
      $log.always("on channel blocks block added on channel #{channel}")
      if block_given?
        @on_channel_blocks ||= HashWithIndifferentAccess.new
        @on_channel_blocks[channel] ||= []
        @on_channel_blocks[channel] << block
      end
      $log.always("on channel blocks #{@on_channel_blocks.inspect}")
    end

    def update(jobservable, messageHolder)
      WEBSOCKET_LOCK.synchronized do
        msg = messageHolder.get_message
        websocket = messageHolder.getWebSocketSupport
        channel = websocket.getChannel #will always be nil/null on the first message
        channel_websockets = channel.nil? ? [] : WebSocketSupport.websockets[channel]
        $log.always {"This websocket is chatting on channel #{channel}"}
        @on_message_blocks.each do |block|
          terminate_notifications = false
          begin
            $log.always {"start block"}
            unless terminate_notifications.eql? TerminateNotifications
              terminate_notifications = block.call(msg, messageHolder, websocket) #wrap up in begin/rescue to prevent breaking the observer/observable notification chain
            end
            $log.always {"end block"}
          rescue => ex
            $log.error(LEX("Something went wrong processing a websocket message!", ex))
          end
        end
        unless channel.nil?
          $log.always {"on channel blocks is #{@on_channel_blocks.inspect}, for channel #{channel}"}
          @on_channel_blocks[channel].each do |block|
            begin
              $log.always {"start block on channel #{channel}"}
              block.call(msg, messageHolder, websocket, channel)
              $log.always {"end block on channel #{channel}"}
            rescue => ex
              $log.error(LEX("Something went wrong processing a websocket message on #{channel}!", ex))
            end
          end
        end
      end
    end

    def add_websocket(channel:, websocket:)
      $log.always("Adding to channel #{channel} websocket #{websocket}")
      WebSocketSupport.validate(channel: channel)
      $log.always("Channel #{channel} is valid")
      WEBSOCKET_LOCK.synchronized do
        websocket.setChannel(channel)
        WebSocketSupport.websockets[channel] ||= []
        WebSocketSupport.websockets[channel] << websocket unless WebSocketSupport.websockets[channel].include? websocket
      end
    end

    private
    def initialize
      WebSocketSupport::WebSocketRemovedObserver.instance #forces a registration, observe removed websocket before we receive messages.
      $log.always("About to register as an observer")
      JWebSocketSupport.getMessageNotifier.addObserver(self)
      $log.always("Registered as an observer")
      @channels = HashWithIndifferentAccess.new
    end

    #this fellow is (and must remain) the first registered block for websocket message processing
    #it checks to see if the websocket should be registered against a broadcast channel
    WebSocketMessageObserver.instance.message_received do |msg, chatter, websocket|
      if websocket.getChannel.nil?
        $log.always("first block got msg #{msg}")
        rval = nil
        begin
          hash = HashWithIndifferentAccess.new JSON.parse msg
          $log.always("first block hash #{hash}")
          if hash[WebSocketSupport::ChannelSetup::BROADCAST_CHANNEL_SETUP]
            WebSocketMessageObserver.instance.add_websocket(channel: hash[ChannelSetup::BROADCAST_CHANNEL_SETUP], websocket: websocket)
            rval = TerminateNotifications
          end
        rescue => ex
          $log.error(LEX("I could not process the incoming websocket message.", ex))
        end
        rval
      end
    end
  end
end

WEBSOCKET_MSG_RCVD = WebSocketSupport::WebSocketMessageObserver.instance

#to process a message

WEBSOCKET_MSG_RCVD.message_received do |msg, chatter, websocket|
  #msg is a string, chatter is gov.va.rails.WebSocketSupport$MessageHolder, websocket is gov.va.rails.WebSocketSupport
  $log.always {"Message recieved from the client YaY!!!  #{msg}"}
end

WEBSOCKET_MSG_RCVD.message_received do |msg, chatter|
  $log.always {"Chat back time!!!!! #{chatter} #{chatter.java_class}"}
  received = chatter.chat("Got your message #{msg} at #{Time.now}")
  $log.always {"Response sent!"} if received
  $log.always {"Response not sent!"} unless received
end

WEBSOCKET_MSG_RCVD.channel_message_received(channel: WebSocketSupport::Channels::ROOT_BEER) do |msg|
  $log.always("from a websocket on the root beer channel I got the message #{msg}")
end

WEBSOCKET_MSG_RCVD.channel_message_received(channel: WebSocketSupport::Channels::ROOT_BEER) do |msg, chatter|
  chatter.chat("got the root beer! #{Time.now}")
end

WEBSOCKET_MSG_RCVD.channel_message_received(channel: WebSocketSupport::Channels::COKE) do |msg|
  $log.always("from a websocket on the coke channel I got the message #{msg}")
end


at_exit do
  JWebSocketSupport.getMessageNotifier.deleteObserver(WEBSOCKET_MSG_RCVD) #no memory leaks on undeploy!
  JWebSocketSupport.getWebSocketRemovedNotifier.deleteObserver(WebSocketSupport::WebSocketRemovedObserver.instance) #no memory leaks on undeploy!
end
