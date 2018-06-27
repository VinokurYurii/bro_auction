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
  attr_accessor :user_alias

  after_create :check_lot

  validates :proposed_price, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validate :is_proposed_price_greater_than_current, :is_user_different_from_creator, :lot_status_in_progress

  scope :lot_bids, -> (lot_id) { where(lot_id: lot_id).order(proposed_price: :desc) }

  enum status: [:pending, :sent, :delivered ]
  enum arrival_type: [:pickup, :royal_mail, :united_states_postal_service, :dhl_express]

  def is_winner
    @is_winner = lot.status == "closed" && lot.bids.order(proposed_price: :desc).first.id == id
  end

  private
    def check_lot
      lot.close if proposed_price >= lot.estimated_price
    end

    def is_proposed_price_greater_than_current
      if proposed_price < lot.current_price
        errors.add(:proposed_price, "Proposed_price must be greater that lot.current_price")
      end
    end

    def is_user_different_from_creator
      if user == lot.user
        errors.add(:user, "Lot creator couldn't create bid for his lot(s)")
      end
    end

    def lot_status_in_progress
      if lot.status != "in_progress"
        errors.add(:lot, "Lot status must be 'in_progress'")
      end
    end
end
