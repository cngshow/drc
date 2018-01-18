class WelcomeController < ApplicationController

  LOCK = java.lang.Object.new

  def index
    LOCK.synchronized do
      @@kicked ||= false
      unless @@kicked
        ChatJob.perform_later
      end
      @@kicked = true
    end
  end
end