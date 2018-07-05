# frozen_string_literal: true

class OrdersController < ApiController
  def create
    lot_id = params[:lot_id]
    user_max_bid = Lot.find(lot_id).max_bids.where(bids: { user_id: current_user.id }).first
    authorize user_max_bid, :can_create_order?
    render_resource_or_errors Order.create(create_params.merge(lot_id: lot_id, bid: user_max_bid))
  end

  def update
    @order = Order.find(params[:id]).define_current_user_role current_user.id
    authorize @order
    if @order.current_user_role == "owner"
      @order.mark_as_sent
    else
      if @order.status == "pending"
        @order.change_arrival_params(create_params)
      else
        @order.mark_as_delivered
      end
    end
    render_resource_or_errors @order
  end

  def create_params
    params.require(:order).permit(:arrival_type, :arrival_location)
  end
end
