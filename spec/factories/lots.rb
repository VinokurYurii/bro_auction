# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  estimated_price :decimal(12, 2)   not null
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  start_price     :decimal(12, 2)   not null
#  status          :integer          default("pending"), not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer          not null
#
# Indexes
#
#  index_lots_on_created_at  (created_at)
#  index_lots_on_user_id     (user_id)
#

FactoryBot.define do
  time = DateTime.now
  factory :lot do
    title { Faker::GameOfThrones.city }
    image nil
    description { Faker::GameOfThrones.quote }
    start_price { rand(1000..9999).to_f }
    estimated_price { rand(100000..100000).to_f }
    lot_start_time time + 1.hour
    lot_end_time time + 1.month
    created_at time
    updated_at time
    status :in_progress
  end
end
