# frozen_string_literal: true

class BidPolicy < ApplicationPolicy
  def can_create_order?
    record.is_winner?
  end

  def destroy?
    record.lot.in_progress? && record.user_id == user.id
  end
end
