# frozen_string_literal: true

class BidSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :lot_id, :user_id, :created_at
  has_one :user, serializer: UserSerializer
  has_one :lot, serializer: LotSerializer
end
