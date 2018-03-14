module ServletSupport

  SERVLET_REQUEST = 'java.servlet_request'

  class << self
    attr_accessor :context#populated after the very firs request/response cycle
  end

  def servlet_response
    request.headers[SERVLET_REQUEST]
  end

  #returns the host beneath the proxy
  def true_address
    addr = servlet_response.getLocalName
    $log.debug("True address/hostname is #{addr}")
    addr
  end

  #returns the port beneath the proxy
  def true_port
    port = servlet_response.getLocalPort
    $log.debug("True port is #{port}")
    port
  end

  def context
    ServletSupport.context ||= servlet_response.getServletContext.getContextPath
  end

  #returns the scheme beneath the proxy
  def secure?
    s = servlet_response.isSecure
    $log.debug("is https? #{s}")
    s
  end

  def non_proxy_url(path_string:)
    path_string = '/' + path_string unless path_string.start_with? '/'
    scheme = secure? ?  'https' : 'http'
    path = scheme + '://' + true_address.to_s + ':'  + true_port.to_s + path_string
    path.gsub!('0:0:0:0:0:0:0:1', 'localhost')
    path.gsub!('127.0.0.1', 'localhost')
    $log.debug("Non proxy path is #{path}")
    path
  end

  def proxify(path:)
    URI(non_proxy_url(path_string: path)).proxify.to_s
  end

end