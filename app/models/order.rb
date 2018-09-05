# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :bigint(8)        not null, primary key
#  arrival_location :string
#  arrival_type     :integer          not null
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bid_id           :integer          not null
#  lot_id           :integer          not null
#
# Indexes
#
#  index_orders_on_bid_id  (bid_id)
#  index_orders_on_lot_id  (lot_id)
#

class Order < ApplicationRecord
  belongs_to :bid
  belongs_to :lot
  attr_reader :current_user_role

  validates :arrival_type, :arrival_location, presence: true
  validate :lot_must_be_closed, :bid_must_be_winner

  after_create :send_email_for_owner

  enum status: [:pending, :sent, :delivered ]
  enum arrival_type: [:pickup, :royal_mail, :united_states_postal_service, :dhl_express]

  def lot_must_be_closed
    if lot.status != "closed"
      errors.add(:lot, "Lot must be closed for creating order")
    end
  end

  def bid_must_be_winner
    unless bid.is_winner?
      errors.add(:bid, "Only winner bid must be in order")
    end
  end

  def send_email_for_owner
    UserMailer.email_about_create_order self
  end

  def change_arrival_params(params)
    self.update params
    UserMailer.email_about_change_arrival_params self
    self
  end

  def mark_as_sent
    self.update status: :sent
    UserMailer.email_about_sending_good self
    self
  end

  def mark_as_delivered
    self.update status: :delivered
    UserMailer.email_about_delivering_good self
    self
  end

  def define_current_user_role(current_user_id)
    if bid.user_id == current_user_id
      @current_user_role = "winner"
    elsif lot.user_id == current_user_id
      @current_user_role = "owner"
    end
    self
  end
end
