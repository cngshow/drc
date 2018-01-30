class UtilitiesController < ApplicationController
  def ajax_show_headers
    headers = []

    request.headers.each do |elem|
      row = {header_key: elem.first.to_s, header_value: elem.last.to_s}
      headers << row
    end
    render :json => headers
  end
end
