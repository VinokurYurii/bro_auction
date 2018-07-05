# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def update?
    (record.current_user_role && !record.delivered?) && (record.pending? || record.current_user_role == "winner")
  end
end
