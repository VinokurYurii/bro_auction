# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  
  protect_from_forgery with: :exception
  before_action :configure_sign_up_params, if: :devise_controller?

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: [:first_name,
                                             :last_name,
                                             :email,
                                             :birth_day,
                                             :phone,
                                             :password,
                                             :password_confirmation])
  end
end
