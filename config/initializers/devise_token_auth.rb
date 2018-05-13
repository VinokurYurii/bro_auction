DeviseTokenAuth.setup do |config|
  config.remove_tokens_after_password_reset = true
  config.default_confirm_success_url = "/"
  config.default_password_reset_url = "/"
  config.change_headers_on_each_request = false
  config.check_current_password_before_update = :password
end
