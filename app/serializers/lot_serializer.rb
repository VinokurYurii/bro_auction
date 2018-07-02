# frozen_string_literal: true

class LotSerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :user_id, :description, :status, :start_price, :user_won,
             :estimated_price, :lot_start_time, :lot_end_time, :created_at, :updated_at, :is_my
  has_one :user, serializer: UserSerializer
  has_many :bids, serializer: BidSerializer
end
