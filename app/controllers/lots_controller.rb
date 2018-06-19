# frozen_string_literal: true

class LotsController < ApiController
  def index
    skip_authorization
    if user_id = params[:user_id]
      return render_resources Lot.find_user_lots(user_id.to_i, current_user.id).order(id: :desc),
                              post_process: true,
                              post_process_function: :check_lots_for_is_my
    end
    render_resources Lot.where(status: :in_progress).order(id: :desc),
                     post_process: true,
                     post_process_function: :check_lots_for_is_my
  end

  def create
    skip_authorization
    render_resource_or_errors(Lot.create(create_params.merge(user_id: current_user.id)))
  end

  def show
    begin
      @lot = Lot.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      skip_authorization
      return render json: { error: "RecordNotFound" }, status: :not_found
    end
    authorize @lot
    render_resource @lot,
                    post_process: true,
                    post_process_function: :is_lot_winner
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
