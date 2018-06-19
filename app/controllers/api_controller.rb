# frozen_string_literal: true

class ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include RenderMethods
  include ChangeProperty

  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "You are not authorized for this action" }, status: :unprocessable_entity
  end
end
