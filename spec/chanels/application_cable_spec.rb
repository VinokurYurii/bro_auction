require "rails_helper"
# frozen_string_literal: true

RSpec.describe ApplicationCable::Connection, type: :channel do
  before do
    @user = create :user
    @logged_user_headers = @user.create_new_auth_token
  end

  it "confirm connection with authentication" do
    connect "/cable", headers: @logged_user_headers
    expect(connection.current_user.id).to eq @user.id
  end
  it "rejects connection without authentication" do
    expect { connect "/cable" } .to have_rejected_connection
  end
end
