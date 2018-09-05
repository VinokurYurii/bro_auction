# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        token = request.headers["access-token"]
        client = request.headers["client"]
        uid = request.headers["uid"]
        user = User.find_by(uid: uid)
        if user && user.valid_token?(token, client)
          user
        else
          reject_unauthorized_connection
        end
      end
  end
end
