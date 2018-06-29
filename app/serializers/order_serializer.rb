# frozen_string_literal: true

class OrderSerializer < ActiveModel::Serializer
  attributes :arrival_location, :arrival_type, :status, :updated_at, :current_user_role
end
