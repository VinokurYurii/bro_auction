# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :bid
  belongs_to :lot
end
