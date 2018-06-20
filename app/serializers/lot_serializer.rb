# frozen_string_literal: true

class LotSerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :user_id, :description, :status, :start_price,
             :estimated_price, :lot_start_time, :lot_end_time, :created_at, :updated_at
  has_one :user, serializer: UserSerializer
end