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

  def email_about_create_order(order)
    @order = order
    @lot = @order.lot
    @lot_link = make_lot_link "Your lot"
    mail(to: @lot.user.email, subject: "Auction winner was create order for your #{ @lot.title } lot")
  end

  def email_about_change_arrival_params(order)
    @order = order
    @lot = @order.lot
    @lot_link = make_lot_link "Your lot"
    mail(to: @lot.user.email, subject: "Your lot winner has change arrival data for your #{ @lot.title } lot")
  end

  def email_about_sending_good(order)
    @order = order
    @lot = @order.lot
    @lot_link = make_lot_link "Your won lot"
    mail(to: @order.bid.user.email, subject: "Your won #{ @lot.title } lot was sent by seller")
  end

  def email_about_delivering_good(order)
    @order = order
    @lot = @order.lot
    mail(to: @lot.user.email, subject: "Your lot #{ @lot.title } was successfully delivered")
  end

  private
    def make_lot_link(link_text)
      "<a href='" + lots_url + "/" + @lot.id.to_s + "'>" + link_text + "</a>"
    end
end
