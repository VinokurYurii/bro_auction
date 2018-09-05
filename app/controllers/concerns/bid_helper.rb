# frozen_string_literal: true

module BidHelper
  extend ActiveSupport::Concern

  private
    def add_bids_participants_aliases(bids)
      user_aliases = {}
      bids.map do |bid|
        unless user_aliases[bid.user_id]
          user_aliases[bid.user_id] = ApplicationRecord.generate_hash [bid.lot_id, bid.user_id]
        end
        bid.user_alias = user_aliases[bid.user_id]
      end
    end
end
