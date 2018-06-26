# frozen_string_literal: true

# == Schema Information
#
# Table name: bids
#
#  id             :bigint(8)        not null, primary key
#  proposed_price :float            not null
#  created_at     :datetime
#  lot_id         :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_bids_on_lot_id              (lot_id)
#  index_bids_on_user_id             (user_id)
#  index_bids_on_user_id_and_lot_id  (user_id,lot_id)
#


FactoryBot.define do
  factory :bid do
    proposed_price { rand(1000..9999).to_f }
    created_at { DateTime.now + rand(1..25).days }
  end
end
