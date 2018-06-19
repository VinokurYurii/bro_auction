# frozen_string_literal: true

class LotPolicy < ApplicationPolicy
  attr_reader :user, :lot
  class Scope < Scope
    def resolve
      scope.where(status: 1)
    end
  end

  def initialize(user, lot)
    @user = user
    @lot  = lot
  end

  def update?
    lot.user.id == user.id
  end

  # def resolve
  #   if lot.user.id == user.id
  #     scope.all
  #   else
  #     scope.where(status: 1)
  #   end
  # end
end
