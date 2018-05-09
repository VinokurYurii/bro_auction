class UserController < ActionController::Base
  before_action :authenticate_user!, except: [:login, :sign_up]
  # protect_from_forgery prepend: true, with: :exception

  def login

  end

  def logout

  end

  def sign_up
    @method = request.method
    @data = nil
    if @method == 'POST'
      @data = params[:user][:name]
      p @data
    end
  end
end
