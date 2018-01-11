class Webpacker::Configuration
  def public_output_path
    if CATALINA_HOME
      Pathname.new "#{Rails.root.to_s}/../#{fetch(:public_output_path)}"
    else
      public_path.join(fetch(:public_output_path))
    end
  end
end