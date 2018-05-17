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
      expect(confirmation_email.body.to_s).to match /Mail for confirmation registration for #{data[:email]}!/
    end


    it "email confirmation link" do
      subject
      confirmation_email = Devise.mailer.deliveries.last
      /href="(?<confirmation_link>.+)"/ =~ confirmation_email.body.to_s
      get confirmation_link
      expect(response.status).to eq 302
    end
  end
end