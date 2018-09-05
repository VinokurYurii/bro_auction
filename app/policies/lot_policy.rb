# frozen_string_literal: true

class LotPolicy < ApplicationPolicy
  def update?
    has_manipulation_rights?
  end

  def destroy?
    has_manipulation_rights?
  end

  def show?
    record.user_id == user.id || %w[in_progress closed].include?(record.status)
  end

  private
    def has_manipulation_rights?
      record.user_id == user.id && record.status == "pending"
    end
end
