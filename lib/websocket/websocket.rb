if ENV['LOAD_WEBSOCKET_JARS']
  urls = []
  urls << java.io.File.new("#{Rails.root}/lib/websocket/railswebsocket.jar").toURI.toURL
  urls << java.io.File.new("#{Rails.root}/lib/jars/javax.websocket-api.jar").toURI.toURL
  urls << java.io.File.new("#{Rails.root}/lib/jars/juli.jar").toURI.toURL

  urls.each do |url|
    java.lang.ClassLoader.getSystemClassLoader.addURL(url) #put it high up on the classloader chain so Tomcat finds it and instantiates with the first 'ws://...' request.
  end
end

java_import 'gov.va.rails.WebSocketSupport' do |p, c|
  'JWebSocketSupport'
end

class IncomingMessageObserver
  include java.util.Observer
  include Singleton

  def message_received(&block)
    if block_given?
      @blocks ||= []
      @blocks << block
    end
  end

  def update(jobservable, messageHolder)
    msg = messageHolder.get_message
    websocket = messageHolder.getWebSocketSupport
    @blocks.each do |block|
      begin
        $log.always {"start block"}
        block.call(msg, messageHolder, websocket) #wrap up in begin/rescue to prevent breaking the observer/observable notification chain
        $log.always {"end block"}
      rescue => ex
        $log.error(LEX("Something went wrong processing a websocket message!", ex))
      end
    end
  end

  private
  def initialize
    $log.always("About to register as an observer")
    JWebSocketSupport.getMessageNotifier.addObserver(self)
    $log.always("Registered as an observer")
  end
end

MESSAGE_OBSERVER = IncomingMessageObserver.instance

#to process a message

MESSAGE_OBSERVER.message_received do |msg, chatter, websocket|
  #msg is a string, chatter is gov.va.rails.WebSocketSupport$MessageHolder, websocket is gov.va.rails.WebSocketSupport
  $log.always {"Message recieved from the client YaY!!!  #{msg}"}
end

MESSAGE_OBSERVER.message_received do |msg, chatter|
  $log.always {"Chat back time!!!!! #{chatter} #{chatter.java_class}"}
  received = chatter.chat("Got your message #{msg} at #{Time.now}")
  $log.always {"Response sent!"} if received
  $log.always {"Response not sent!"} unless received
end

at_exit do
  JWebSocketSupport.getMessageNotifier.deleteObserver(MESSAGE_OBSERVER) #no memory leaks on undeploy!
end
