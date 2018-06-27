# frozen_string_literal: true

class BidsController < ApiController
  def index
    skip_authorization
    render_resource_or_errors add_bids_participants_aliases Bid.lot_bids(params[:lot_id])
  end

  def create
    skip_authorization
    render_resource_or_errors(Bid.create(create_params.merge(user_id: current_user.id)))
  end

  def create_params
    params.require(:bid).permit(:proposed_price, :lot_id)
  end
end
