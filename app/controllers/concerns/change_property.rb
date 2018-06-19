# frozen_string_literal: true

module ChangeProperty
  extend ActiveSupport::Concern

  private
    def add_bids_participants_aliases(bids)
      user_aliases = {}
      bid_user_counter = 1
      bids.map do |bid|
        if current_user.id == bid.user_id
          bid.user_alias = "Your"
        else
          unless user_aliases[bid.user_id]
            user_aliases[bid.user_id] = "Customer #{bid_user_counter}"
            bid_user_counter += 1
          end
          bid.user_alias = user_aliases[bid.user_id]
        end
      end
    end

    def check_lots_for_is_my(lots)
      lots.map do |lot|
        lot.is_my = (lot.user_id == current_user.id)
      end
    end

    def is_lot_winner(lot)
      if lot.status == "closed" && lot.bids.count > 0
        lot.user_won = lot.bids.order(proposed_price: :desc).first.user_id == current_user.id
      end
    end
end
