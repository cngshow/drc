module RouteHelper
  include Webpacker::Helper
  include ActionView::Helpers::AssetUrlHelper
  include ServletSupport

  IMAGE_EXTENSIONS = ['.jpeg', '.jpg','.png','.gif' ].freeze
  IMAGE_ROOT_PATH = 'packs/images/'

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
    @@routes_hash
  end

  def setup_packed_assets
    if Webpacker.instance.config.cache_manifest?
      @@packed_assets ||= packed_assets
    else
      @@packed_assets = packed_assets
    end
  end

  def get_websocket_url(context:)
    u = URI root_url.chop!.reverse.sub(relative_url_root.reverse,'').reverse+"#{context}#{WEBSOCKET_ENDPOINT}"
    u.port = 8090 if Rails.env.development?
    scheme = secure? ? 'wss' : 'ws'
    u.scheme = scheme
    u.to_s
  end

  private

  def packed_assets
    h = {}
    h[:paths] = {}
    h[:urls] = {}
    h[:urls][:images] = {}
    h[:paths][:images] = {}
    Webpacker.instance.manifest.refresh.each_pair do |k,v|
      unless k =~ /map$/
        url = asset_pack_url k
        path = asset_pack_path k
        h[:urls][k] = url
        h[:paths][k] = path
        if IMAGE_EXTENSIONS.include?(File.extname k)
          rootless = k.sub(IMAGE_ROOT_PATH,'')
          h[:urls][:images][k] = url
          h[:urls][:images][rootless] = url
          h[:paths][:images][k] = path
          h[:paths][:images][rootless] = path
        end
      end
    end
    h
  end

end
=begin
Webpacker.instance.manifest
Webpacker.instance.manifest.refresh #gives hash
include Webpacker::Helper
include ActionView::Helpers::AssetUrlHelper
include ActionView::Helpers::AssetTagHelper
Webpacker.instance.config.cache_manifest?

=end