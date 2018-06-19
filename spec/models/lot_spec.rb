# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id              :bigint(8)        not null, primary key
#  description     :text
#  estimated_price :decimal(2, 2)    not null
#  image           :string
#  lot_end_time    :datetime
#  lot_start_time  :datetime
#  start_price     :decimal(2, 2)    not null
#  status          :integer          default("pending"), not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_lots_on_created_at  (created_at)
#


require "rails_helper"

RSpec.describe Lot, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
