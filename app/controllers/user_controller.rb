class UserController < ActionController::Base
  before_action :authenticate_user!, except: [:login, :sign_up]
  # protect_from_forgery prepend: true, with: :exception

  def login
    @users = User.find(1).inspect
  end

  def logout

  end

  def sign_up
    @method = request.method
    @data = nil
    if @method == 'POST'
      User.create(
        :first_name => params[:user][:first_name],
        :last_name => params[:user][:last_name],
        :email => params[:user][:email],
        :phone => params[:user][:phone],
        :birth_day => Date.parse(params[:user][:birth_day]).to_date,
        :password => params[:user][:password]
      )


    end
  end
end
