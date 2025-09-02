# app/controllers/omniauth_controller.rb
class OmniauthController < ApplicationController
  def passthru
    render status: 404, plain: "Not found. Authentication passthru."
  end
end
