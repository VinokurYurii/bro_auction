# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_for_winner(lot)
    lot_winner = lot.max_bids.first.user
    @lot = lot
    @lot_link = make_lot_link "Your won lot"
    mail(to: lot_winner.email, subject: "You are won the #{ @lot.title } lot")
  end

  def closing_email_for_lot_owner(lot)
    @lot = lot
    @lot_link = make_lot_link "Your closed lot"
    mail(to: @lot.user.email, subject: "You lot #{ @lot.title } become closed")
  end

  private
    def make_lot_link(link_text)
      "<a href='" + lots_url + "/" + @lot.id.to_s + "'>" + link_text + "</a>"
    end
end
