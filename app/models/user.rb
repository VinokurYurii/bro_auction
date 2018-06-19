# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :lots, dependent: :nullify
  has_many :bids, dependent: :nullify

  validates :email, :first_name, :last_name, :birth_day, :phone, presence: true
  validates :email, :phone, uniqueness: { case_sensitive: false }
  validate :age_must_be_greater_then_21
  def age_must_be_greater_then_21
    if (DateTime.now - 21.years) < birth_day
      errors.add(:birth_day, "Age can't be less then 21 year")
    end
  end
end
