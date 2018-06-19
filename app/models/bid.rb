# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :lot

  enum status: [:pending, :sent, :delivered ]
  enum arrival_type: [:pickup, :royal_mail, :united_states_postal_service, :dhl_express]
end
