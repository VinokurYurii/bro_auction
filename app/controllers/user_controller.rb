class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:login, :sign_up]

  def login

  end

  def logout

  end

  def sign_up

  end
end
