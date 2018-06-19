# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  estimated_price :decimal(2, 2)    not null
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  start_price     :decimal(2, 2)    not null
#  status          :integer          default("pending"), not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_lots_on_created_at  (created_at)
#


class Lot < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :nullify

  enum status: [:pending, :in_progress, :closed]

  validates :title, :status, :current_price, :estimated_price, :created_at, presence: true
  validates :estimated_price, :current_price, numericality: { greater_than_or_equal_to: 0 }
  validate :start_time_less_then_end_time, :created_at_less_then_start_time

  def start_time_less_then_end_time
    if lot_start_time < lot_end_time
      errors.add(:lot_start_time, "Start time must be less than the end time")
    end
  end

  def created_at_less_then_start_time
    if lot_start_time >= (created_at ? created_at : DateTime.now)
      errors.add(:lot_start_time, "Start time must be greeter or equal than current time or created at time")
    end
  end
end
