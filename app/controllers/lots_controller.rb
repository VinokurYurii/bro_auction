# frozen_string_literal: true

class LotsController < ApiController
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  include RenderMethods
  before_action :authenticate_user!
  # protect_from_forgery with: :null_session

  def index
    if user_id = params[:user_id]
      return render json: Lot.find_user_lots(user_id.to_i, current_user.id)
    end
    render json: Lot.where(status: :in_progress)
  end

  def create
    render_resource_or_errors(Lot.create(create_params.merge(user_id: current_user.id)))
  end

  def show
  end

  def create_params
    params.require(:lot).permit(:title,
        :image,
        :description,
        :status,
        :start_price,
        :estimated_price,
        :lot_start_time,
        :lot_end_time)
  end
end
