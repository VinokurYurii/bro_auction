# frozen_string_literal: true

class BidsController < ApiController
  before_action :authenticate_user!


  def index
    skip_authorization
    render_resource_or_errors Bid.lot_bids(params[:lot_id])
  end

  def create
    # skip_authorization
    # render_resource_or_errors(Lot.create(create_params.merge(user_id: current_user.id)))
  end

  def show
    # @lot = Lot.find(params[:id])
    # authorize @lot
    # render_resource_or_errors(@lot)
  end

  def destroy
    # @lot = Lot.find(params[:id])
    # if authorize @lot
    #   render_resource_or_errors @lot.destroy
    # end
  end

  def update
    # @lot = Lot.find(params[:id])
    # if authorize @lot
    #   @lot.update create_params
    #   render_resource_or_errors @lot
    # end
  end

  def create_params
    params.require(:bid).permit(:proposed_price)
  end
end
