Rails.application.routes.draw do
  class OnlyAjaxRequest
    def matches?(request)
      request.xhr? || Rails.env.development?
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'welcome#index'

  get 'fetch_text/fetch_text', :as => :fetch_text
  get 'show_headers' => 'utilities#ajax_show_headers', :constraints => OnlyAjaxRequest.new
  post 'submit_form' => 'utilities#ajax_form_submission'
end
