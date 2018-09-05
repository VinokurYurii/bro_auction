require "digest"
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Kaminari
  self.abstract_class = true

  def self.generate_hash(args, length = 10)
    (Digest::SHA256.hexdigest args.join)[1..length]
  end
end
