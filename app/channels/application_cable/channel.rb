module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

class ReactChannel < ApplicationCable::Channel
  # def subscribed
  #   stream_from "chat_#{params[:room]}"
  # end
  #
  # def subscribed
  #   post = Post.find(params[:id])
  #   stream_for post
  # end

end
