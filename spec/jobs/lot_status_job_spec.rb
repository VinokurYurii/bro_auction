# frozen_string_literal: true

require "rails_helper"

RSpec.describe LotStatusJob, type: :job do
  before :each do
    @user = create :user
  end
  describe "LotStatusJob" do
    it "s" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        LotStatusJob.perform_later
      }.to have_enqueued_job
    end
  end
end
