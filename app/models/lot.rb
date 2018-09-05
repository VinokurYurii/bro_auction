# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  estimated_price :decimal(12, 2)   not null
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  start_price     :decimal(12, 2)   not null
#  status          :integer          default("pending"), not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_lots_on_created_at  (created_at)
#  index_lots_on_user_id     (user_id)
#

class Lot < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :nullify
  attr_accessor :is_my, :user_won, :user_identifier

  paginates_per 10

  enum status: [:pending, :in_progress, :closed]

  validates :title, :status, :start_price, :estimated_price, :lot_start_time, :lot_end_time, presence: true
  validates :estimated_price, :start_price, numericality: { greater_than_or_equal_to: 0 }
  validate :start_time_less_then_end_time, :created_at_less_then_start_time

  def max_bids
    bids.order(proposed_price: :desc)
  end

  def self.find_user_lots(user_id, current_user_id)
    if user_id == current_user_id
      return Lot.left_joins(:bids).where("lots.user_id = :user_id OR bids.user_id = :user_id", user_id: user_id)
    end
    where(user_id: user_id, status: :in_progress)
  end

  def current_price
    if max_bid = max_bids.first
      max_bid.proposed_price
    else
      start_price
    end
  end

  def start_time_less_then_end_time
    if lot_start_time > lot_end_time
      errors.add(:lot_start_time, "Start time must be less than the end time")
    end
  end

  def created_at_less_then_start_time
    if lot_start_time <= (created_at ? created_at : DateTime.now)
      errors.add(:lot_start_time, "Start time must be greeter or equal than current time or created at time " + lot_start_time.to_s + " l2: " + created_at.to_s)
    end
  end

  def check_time_and_status
    time_now = DateTime.now.utc
    if lot_end_time < time_now && status != "closed"
      close
    elsif lot_start_time < time_now && status == "pending"
      update! status: :in_progress
    end
  end

  def close
    update! status: :closed
    unless bids.empty?
      UserMailer.email_for_winner self
    end
    UserMailer.closing_email_for_lot_owner self
  end
end
