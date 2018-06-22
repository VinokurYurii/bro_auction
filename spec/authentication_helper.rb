# frozen_string_literal: true

def login(user, params = {})
  before(:each) do
    @user = create(user, params)
    sign_in @user
    request.headers.merge! @user.create_new_auth_token
  end
end

def login_by_user(user_obj)
  sign_in user_obj
  request.headers.merge! user_obj.create_new_auth_token
end
