# frozen_string_literal: true

class LotStatusJob < ApplicationJob
  queue_as :default

  def perform
    Lot.where("lot_end_time <= :now OR lot_start_time <= :now", now: DateTime.now.utc).find_each do |lot|
      lot.check_time_and_status
    end
  end
end
