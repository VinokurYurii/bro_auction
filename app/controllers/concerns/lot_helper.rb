# frozen_string_literal: true

module LotHelper
  extend ActiveSupport::Concern

  private
    def check_lots_for_is_my(lots)
      lots.map do |lot|
        lot.is_my = (lot.user_id == current_user.id)
      end
    end

    def mark_lot_winner(lot)
      if lot.status == "closed" && lot.bids.count > 0
        lot.user_won = lot.bids.order(proposed_price: :desc).first.user_id == current_user.id
      end
    end
end
