require "rails_helper"
# frozen_string_literal: true

RSpec.describe "Rubocop", type: :rybocop do
  it "Rubocop without errors" do
    result = system "bundle exec rubocop"
    expect(result).to be(true)
  end
end
