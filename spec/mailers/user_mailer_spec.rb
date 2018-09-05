require "rails_helper"
# frozen_string_literal: true

RSpec.describe UserMailer, type: :mailer do
  before :each do
    @user = create :user
    @lot = create :lot, user: @user, start_price: 10.00, estimated_price: 100.00
  end

  context "lot mails" do
    context "Mail for lot owner regarding lot without bids" do
      let(:mail) { UserMailer.closing_email_for_lot_owner(@lot) }

      it "renders lot without winner mail headers" do
        expect(mail.subject).to eq("You lot #{ @lot.title } become closed")
        expect(mail.to).to eq([@user.email])
        expect(mail.from).to eq(["bro_auction@gmail.com"])
      end

      it "renders lot without winner mail body" do
        expect(mail.body.encoded).to match(/Your lot are closed by system<\/br>[\w\W]*No one made bets/)
        expect(mail.body.encoded).to match("<a href='" + lots_url + "/" + @lot.id.to_s + "'>Your closed lot</a>")
      end
    end

    context "Lot with bids" do
      before :each do
        @user2 = create :user
        @bid = create :bid, user: @user2, lot: @lot, proposed_price: 20.00
      end
      context "Mail for lot owner regarding lot with bids" do
        let(:mail) { UserMailer.closing_email_for_lot_owner(@lot) }

        it "renders lot with winner mail headers" do
          expect(mail.subject).to eq("You lot #{ @lot.title } become closed")
          expect(mail.to).to eq([@user.email])
          expect(mail.from).to eq(["bro_auction@gmail.com"])
        end

        it "renders lot with winner mail body" do
          expect(mail.body.encoded).to match("Winner price of your lot is #{@bid.proposed_price}")
          expect(mail.body.encoded).to match("<a href='" + lots_url + "/" + @lot.id.to_s + "'>Your closed lot</a>")
        end
      end

      context "Mail for lot winner regarding won lot" do
        let(:mail) { UserMailer.email_for_winner(@lot) }

        it "renders lot with winner mail headers" do
          expect(mail.subject).to eq("You are won the #{ @lot.title } lot")
          expect(mail.to).to eq([@user2.email])
          expect(mail.from).to eq(["bro_auction@gmail.com"])
        end

        it "renders lot with winner mail body" do
          expect(mail.body.encoded).to match("You are the lot #{ @lot.title } winner")
          expect(mail.body.encoded).to match("<a href='" + lots_url + "/" + @lot.id.to_s + "'>Your won lot</a>")
        end
      end
    end
  end

  context "Order mails" do
    before :each do
      @winner_user = create :user
      @bid = create :bid, user_id: @winner_user.id, proposed_price: 30.00, lot: @lot
      @lot.update! status: :closed
      @order = Order.create lot: @lot, bid: @bid, arrival_location: "Some where", arrival_type: :dhl_express
    end
    context "render mail for owner regarding create order" do
      let(:mail) { UserMailer.email_about_create_order @order }
      it "render headers" do
        expect(mail.subject).to eq "Auction winner was create order for your #{ @lot.title } lot"
        expect(mail.to).to eq [@user.email]
        expect(mail.from).to eq ["bro_auction@gmail.com"]
      end
      it "render body" do
        expect(mail.body.encoded).to match("He chose arrival type: #{ @order.arrival_type }")
        expect(mail.body.encoded).to match("And he will wait his stuff by address: #{ @order.arrival_location }")
        expect(mail.body.encoded).to match("<a href='" + lots_url + "/" + @lot.id.to_s + "'>Your lot</a>")
      end
    end
    context "render mail for owner regarding change arrival params" do
      let(:mail) { UserMailer.email_about_change_arrival_params @order }
      it "render headers" do
        expect(mail.subject).to eq "Your lot winner has change arrival data for your #{ @lot.title } lot"
        expect(mail.to).to eq [@user.email]
        expect(mail.from).to eq ["bro_auction@gmail.com"]
      end
      it "render body" do
        expect(mail.body.encoded).to match("He chose arrival type: #{ @order.arrival_type }")
        expect(mail.body.encoded).to match("And he will wait his stuff by address: #{ @order.arrival_location }")
        expect(mail.body.encoded).to match("<a href='" + lots_url + "/" + @lot.id.to_s + "'>Your lot</a>")
      end
    end
    context "render mail for winner regarding sent lot by owner" do
      let(:mail) { UserMailer.email_about_sending_good @order }
      it "render headers" do
        expect(mail.subject).to eq "Your won #{ @lot.title } lot was sent by seller"
        expect(mail.to).to eq [@winner_user.email]
        expect(mail.from).to eq ["bro_auction@gmail.com"]
      end
      it "render body" do
        expect(mail.body.encoded)
            .to match("Now you can wait your good by #{ @order.arrival_type } on #{ @order.arrival_location }")
      end
    end
    context "render mail for owner regarding deliver lot to winner" do
      let(:mail) { UserMailer.email_about_delivering_good @order }
      it "render headers" do
        expect(mail.subject).to eq "Your lot #{ @lot.title } was successfully delivered"
        expect(mail.to).to eq [@user.email]
        expect(mail.from).to eq ["bro_auction@gmail.com"]
      end
      it "render body" do
        expect(mail.body.encoded)
            .to match("Your lot #{ @lot.title } was successfully delivered and received by lot winner")
      end
    end
  end
end
