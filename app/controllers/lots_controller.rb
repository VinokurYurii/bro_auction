# frozen_string_literal: true

class LotsController < ApiController
  include LotHelper

  swagger_controller :lots, "Lot Management"

  swagger_api :index do
    summary "Fetches Lot items"
    notes "Return list of lots, if defined :user_id it returned user lots list"
    param :query, :page, :integer, :optional, "Page number"
    param :query, :user_id, :integer, :optional, "User id for showing his lots"
    response :ok, "resources", :Lot
    response :requested_range_not_satisfiable
  end

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

  swagger_api :create do
    summary "Create lot"
    notes "Create lot for user"
    param :query, :title, :string, :required, "Lot title"
    param :query, :image, :string, :optional, "Lot image"
    param :query, :description, :string, :optional, "Lot description"
    param :query, :start_price, :decimal, :required, "Lot start price"
    param :query, :estimated_price, :decimal, :required, "Lot estimated price"
    param :query, :lot_start_time, :timestamp, :required, "Lot start time"
    param :query, :lot_end_time, :timestamp, :required, "Lot stop time"
    response :unauthorized
    response :ok, "resources", :Lot
  end

  def create
    skip_authorization
    render_resource_or_errors(Lot.create(create_params.merge(user_id: current_user.id)))
  end

  swagger_api :show do
    summary "Show Lot by id"
    notes "Return lot, if user has rights for it looking"
    param :path, :id, :integer, :required, "Lot id"
    response :ok, "resource", :Lot
    response :requested_range_not_satisfiable
    response :unauthorized
  end

  def show
    begin
      @lot = Lot.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      skip_authorization
      return render json: { error: "Post not fount" }, status: :not_found
    end
    authorize @lot
    @lot.user_identifier = ApplicationRecord.generate_hash [@lot.id, current_user.id]
    render_resource @lot,
                    post_process: true,
                    post_process_function: :mark_lot_winner
  end


  swagger_api :destroy do
    summary "Destroy Lot by id"
    notes "Destroy lot, if user has rights for that action"
    param :path, :id, :integer, :required, "Lot id"
    response :ok, "resource", :Lot
    response :requested_range_not_satisfiable
    response :unauthorized
  end

  def destroy
    @lot = Lot.find(params[:id])
    if authorize @lot
      render_resource_or_errors @lot.destroy
    end
  end

  swagger_api :update do
    summary "Update lot"
    notes "Update lot by creator"
    param :path, :id, :integer, :required, "Lot id"
    param :query, :title, :string, :required, "Lot title"
    param :query, :image, :string, :optional, "Lot image"
    param :query, :description, :string, :optional, "Lot description"
    param :query, :start_price, :decimal, :required, "Lot start price"
    param :query, :estimated_price, :decimal, :required, "Lot estimated price"
    param :query, :lot_start_time, :timestamp, :required, "Lot start time"
    param :query, :lot_end_time, :timestamp, :required, "Lot stop time"
    response :unauthorized
    response :ok, "resources", :Lot
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
        :start_price,
        :estimated_price,
        :lot_start_time,
        :lot_end_time)
  end
end
