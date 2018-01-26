class ApplicationController < ActionController::Base
  include RouteHelper
  protect_from_forgery with: :exception
  rescue_from Exception, java.lang.Throwable, :with => :internal_error
  before_action :setup_gon

  def internal_error(exception)
    $log.error(LEX("An uncaught exception!", exception))
    raise exception
  end

  def setup_gon
    gon.routes = setup_routes
    gon.pack = packed_assets
  end

end
