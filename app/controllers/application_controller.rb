class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from Exception, java.lang.Throwable, :with => :internal_error

  def internal_error(exception)
    $log.error(LEX("An uncaught exception!", exception))
    raise exception
  end

end
