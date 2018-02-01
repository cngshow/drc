require './lib/util/helpers'

urls = []
urls << java.io.File.new("#{Rails.root}/lib/websocket/railswebsocket.jar").toURI.toURL
urls << java.io.File.new("#{Rails.root}/lib/jars/javax.websocket-api.jar").toURI.toURL
urls << java.io.File.new("#{Rails.root}/lib/jars/juli.jar").toURI.toURL

urls.each do |url|
  java.lang.ClassLoader.getSystemClassLoader.addURL(url)#put it high up on the classloader chain so Tomcat finds it and instantiates with the first 'ws://...' request.
end
java_import 'gov.va.rails.WebSocketSupport' do |p,c| 'JWebSocketSupport' end
