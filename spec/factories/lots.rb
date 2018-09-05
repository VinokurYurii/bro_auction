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
    start_price 10.00
    estimated_price 100.00
    lot_start_time time + 15.minutes
    lot_end_time time + 1.day
    created_at time
    updated_at time
    status :in_progress
  end
end
