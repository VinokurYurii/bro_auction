# frozen_string_literal: true

class BidsChannel < ApplicationCable::Channel
  def subscribed
    lot_id = params[:lot_id]
    reject unless lot_id
    stream_from "bids_for_lot_#{ lot_id }"
  end
end
