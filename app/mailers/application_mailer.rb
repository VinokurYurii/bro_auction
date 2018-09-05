# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "bro_auction@gmail.com"
  layout "mailer"
end
