# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Kaminari
  self.abstract_class = true
end
