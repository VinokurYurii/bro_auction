# frozen_string_literal: true

# == Schema Information
#
# Table name: bids
#
#  id             :bigint(8)        not null, primary key
#  proposed_price :float            not null
#  created_at     :datetime
#  lot_id         :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_bids_on_lot_id              (lot_id)
#  index_bids_on_user_id             (user_id)
#  index_bids_on_user_id_and_lot_id  (user_id,lot_id)
#


class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :lot

  scope :max_lot_bid, -> (lot_id) { where(lot_id: lot_id).order(proposed_price: :desc).first }

  enum status: [:pending, :sent, :delivered ]
  enum arrival_type: [:pickup, :royal_mail, :united_states_postal_service, :dhl_express]
end
