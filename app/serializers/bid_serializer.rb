# frozen_string_literal: true

class BidSerializer < ActiveModel::Serializer
  attributes :id, :proposed_price, :user_alias, :created_at, :is_winner
end
