# frozen_string_literal: true

class LotsController < ApiController
  before_action :authenticate_user!
  # protect_from_forgery with: :null_session

  def index
    skip_authorization
    if user_id = params[:user_id]
      return render json: Lot.find_user_lots(user_id.to_i, current_user.id).order(id: :desc).page(params[:page])
    end
    render json: Lot.where(status: :in_progress).order(id: :desc).page(params[:page])
  end

  def create
    skip_authorization
    render_resource_or_errors(Lot.create(create_params.merge(user_id: current_user.id)))
  end

  def show
    @lot = Lot.find(params[:id])
    authorize @lot
    render_resource_or_errors(@lot)
  end

  def destroy
    @lot = Lot.find(params[:id])
    if authorize @lot
      render_resource_or_errors @lot.destroy
    end
  end

  def update
    @lot = Lot.find(params[:id])
    if authorize @lot
      @lot.update create_params
      render_resource_or_errors @lot
    end
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
