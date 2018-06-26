# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_for_winner(lot)
    lot_winner = lot.max_bids.first.user
    @lot = lot
    @mail_text = "Congratulations!<br>
You are the lot #{ @lot.title } winner<br>
Now you can create order<br>"
    @mail_text += make_lot_link "Your wonned lot"
    mail(to: lot_winner.email, subject: "You are won the #{ @lot.title } lot")
  end

  def closing_email_for_lot_owner(lot)
    @lot = lot
    @mail_text = "Your lot are closed by system<br>"
    if lot.bids.empty?
      @mail_text += "No one made bets"
    else
      @mail_text += "Winner price of your lot is #{@lot.current_price}"
    end
    @mail_text += "<br>"
    @mail_text += make_lot_link "Your closed lot"
    mail(to: @lot.user.email, subject: "You lot #{ @lot.title } become closed")
  end

  private
    def make_lot_link(link_text)
      "<a href='" + lots_url + "/" + @lot.id.to_s + "'>" + link_text + "</a>"
    end
end
