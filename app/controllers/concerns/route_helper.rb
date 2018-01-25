module RouteHelper
  def setup_routes
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    routes = Rails.application.routes.named_routes.helper_names
    $VERBOSE = original_verbosity
    @@routes_hash ||= {}
    if @@routes_hash.empty?
      routes.each do |route|
        begin
          @@routes_hash[route] = self.send(route)
        rescue ActionController::UrlGenerationError => ex
          if (ex.message =~ /missing required keys: \[(.*?)\]/)
            keys = $1
            keys = keys.split(',')
            keys.map! do |e|
              e.gsub!(':', '')
              e.strip
            end
            required_keys_hash = {}
            keys.each do |key|
              required_keys_hash[key.to_sym] = ':' + key.to_s
            end
            @@routes_hash[route] = self.send(route, required_keys_hash)
          else
            raise ex
          end
        end
      end
    end
    #$log.debug('routes hash passed to javascript is ' + @@routes_hash.to_s)
    gon.routes = @@routes_hash
  end

end