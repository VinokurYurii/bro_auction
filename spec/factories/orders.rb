# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id               :bigint(8)        not null, primary key
#  arrival_location :string
#  arrival_type     :integer          not null
#  status           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bid_id           :integer          not null
#  lot_id           :integer          not null
#
# Indexes
#
#  index_orders_on_bid_id  (bid_id)
#  index_orders_on_lot_id  (lot_id)
#


FactoryBot.define do
  factory :order do
    arrival_location "MyString"
  end
end
