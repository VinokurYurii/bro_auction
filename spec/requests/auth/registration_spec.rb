require "rails_helper"

RSpec.describe "Registration", type: :request do
  describe "POST create" do

    let(:data) do
      {
          first_name:            "first name",
          last_name:             "last name",
          email:                 "user@example.com",
          password:              "password",
          password_confirmation: "password",
          phone:                 "1234567890",
          birth_day:             22.years.ago
      }
    end

    subject { post "/users", params: data }

    it "response should be success" do
      subject
      expect(response).to be_success
    end

    it "creates new user" do
      expect {
        subject
      }.to change{User.count}.from(0).to(1)
    end

    it "sends a confirmation email" do
      expect { subject }.to change( Devise.mailer.deliveries, :count ).by(1)
    end

    it "send a email confirmation with custom text" do
      subject
      confirmation_email = Devise.mailer.deliveries.last
      expect(data[:email]).to eq confirmation_email.to[0]
      expect(confirmation_email.body.to_s).to eq "<p>Mail for confirmation registration for #{data[:email]}!</p>\n\n<!--<p> </p>-->\n\n<!--<p></p>-->\n"
      # expect(confirmation_email.body.to_s).to have_content 'John says Hi!'
    end
  end
end