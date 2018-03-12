require './lib/websocket/channels'

jars = Dir.glob("#{Rails.root}/lib/websocket/*.jar")
require jars.first
#todo delete lines three and four when this jar becomes any old boring dependency managed by maven

java_import 'gov.va.rails.websocket.WebSocketSupport' do |p, c|
  'JWebSocketSupport'
end

module WebSocketSupport

  WEBSOCKET_LOCK = java.lang.Object.new

  class << self
    attr_accessor :websockets_by_channel
    attr_accessor :websockets_by_client

    def validate(channel:)
      valid = WebSocketSupport::Channels.constants.map {|c| WebSocketSupport::Channels.const_get(c)}
      raise ArgumentError.new("Channel #{channel} is invalid.  Valid channels are #{valid}.") unless valid.include? channel.to_sym
    end

    def broadcast_all(message:)
      JWebSocketSupport.broadcast(message)
    end

    def client_chat(uuid:, client_uuid:, message:)
      chat(key: [uuid, client_uuid], message: message, collection: WebSocketSupport.websockets_by_client)
    end

    def broadcast(channel:, message:)
      validate(channel: channel)
      chat(key: channel, message: message, collection: WebSocketSupport.websockets_by_channel)
    end

    private
    def chat(key:, message:, collection:)
      $log.always("broadcast to #{key} with message #{message}")
      $log.always("The websockets are: #{collection[key]}")
      $log.always("All the websockets are: #{collection}")
      WEBSOCKET_LOCK.synchronized do
        invalid_sockets = []
        collection[key]&.each do |socket|
          if socket.isPresent
            $log.always {"broadcasting to #{key} on #{socket}"}
            success = JWebSocketSupport.chat(socket, message)
            $log.always {"broadcast to #{socket} was successful? #{success}"}
          else
            invalid_sockets << socket
            $log.always {"broadcast of #{message} to #{socket} failed as the socket is no longer active."}
          end
        end
        collection[key] = collection[key] - invalid_sockets rescue collection[key] #in case we are nil we stay nil.
      end
    end
  end
  WebSocketSupport.websockets_by_channel = HashWithIndifferentAccess.new
  WebSocketSupport.websockets_by_client = {}

  module TerminateNotifications
  end

  class WebSocketRemovedObserver
    include java.util.Observer
    include Singleton, WebSocketSupport::Channels

    def update(jobservable, websocket)
      $log.always("Attempting removal #{jobservable}, #{jobservable.java_class}, with #{websocket}")
      WEBSOCKET_LOCK.synchronized do
        [WebSocketSupport.websockets_by_channel, WebSocketSupport.websockets_by_client].each do |hash|
          hash.each_pair do |key, value|
            value.delete_if do |socket|
              remove = socket.eql? websocket
              $log.always {"Removal of #{websocket} occurred from #{hash}"}
              remove
            end
          end
        end
      end
    end

    private
    def initialize
      JWebSocketSupport.getWebSocketRemovedNotifier.addObserver(self)
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

    #useful in testing, to ensure only blocks under test are executed.
    def clear
      @on_channel_blocks = HashWithIndifferentAccess.new
      first = @on_message_blocks.first
      @on_message_blocks = [first]
    end

    def update(jobservable, messageHolder)
      WEBSOCKET_LOCK.synchronized do
        msg = messageHolder.get_message
        websocket = messageHolder.getWebSocketSupport
        intial_data = HashWithIndifferentAccess.new(JSON.parse websocket.getInitialData) rescue nil#will always be nil/null on the first message
        channel = intial_data[WebSocketSetup::BROADCAST_CHANNEL_SETUP] rescue nil
        $log.always("Got message #{msg}, with #{intial_data}, against channel #{channel}")
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
          @on_channel_blocks[channel]&.each do |block|
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

    def add_websocket(channel:, websocket:, server_uuid:, client_uuid:)
      $log.always("Adding to channel #{channel} websocket #{websocket}")
      WebSocketSupport.validate(channel: channel)
      $log.always("Channel #{channel} is valid")
      WEBSOCKET_LOCK.synchronized do
        WebSocketSupport.websockets_by_channel[channel] ||= []
        WebSocketSupport.websockets_by_channel[channel] << websocket unless WebSocketSupport.websockets_by_channel[channel].include? websocket
        WebSocketSupport.websockets_by_client[[server_uuid, client_uuid]] ||= []
        WebSocketSupport.websockets_by_client[[server_uuid, client_uuid]] << websocket unless WebSocketSupport.websockets_by_client[[server_uuid, client_uuid]].include? websocket
      end
    end

    private
    def initialize
      WebSocketSupport::WebSocketRemovedObserver.instance #forces a registration, observe removed websockets before we receive messages.
      $log.always("About to register as an observer")
      JWebSocketSupport.getMessageNotifier.addObserver(self)
      $log.always("Registered as an observer")
      @channels = HashWithIndifferentAccess.new
    end

    #this fellow is (and must remain) the first registered block for websocket message processing
    #it checks to see if the websocket should be registered against a broadcast channel
    WebSocketMessageObserver.instance.message_received do |msg, chatter, websocket|
      if websocket.getInitialData.nil?
        $log.always("first block got msg #{msg}")
        rval = nil
        begin
          hash = HashWithIndifferentAccess.new JSON.parse msg
          websocket.setInitialData(msg)
          $log.always("first block hash #{hash}")
          channel = hash[WebSocketSupport::WebSocketSetup::BROADCAST_CHANNEL_SETUP]
          uuid = hash[WebSocketSupport::WebSocketSetup::SERVER_UUID]
          client_uuid = hash[WebSocketSupport::WebSocketSetup::CLIENT_UUID]
          if (channel && uuid && client_uuid)
            WebSocketMessageObserver.instance.add_websocket(channel: channel, server_uuid: uuid, client_uuid: client_uuid, websocket: websocket)
            rval = TerminateNotifications
          end
        rescue => ex
          $log.error(LEX("I could not process the incoming websocket message.", ex))
        end
        rval
      end
    end
  end

  class Logger
    include gov.va.rails.websocket.RailsLogging

    def trace(msg, ex)
      $log.always(LEX(msg, ex)) #todo trace
    end

    def debug(msg, ex)
      $log.always(LEX(msg, ex)) #todo debug
    end

    def info(msg, ex)
      $log.always(LEX(msg, ex)) #todo info
    end

    def warn(msg, ex)
      $log.warn(LEX(msg, ex))
    end

    def error(msg, ex)
      $log.error(LEX(msg, ex))
    end

    def fatal(msg, ex)
      $log.fatal(LEX(msg, ex))
    end

    def always(msg, ex)
      $log.always(LEX(msg, ex))
    end
  end
end
JWebSocketSupport.setLogger(WebSocketSupport::Logger.new)

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
  JWebSocketSupport.setLogger(nil) #no memory leaks on undeploy!
end
