class WelcomeController < ApplicationController

  def index
    @data = {name: 'greg', age: 888}
  end
end