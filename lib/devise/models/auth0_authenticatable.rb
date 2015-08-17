require 'devise'

module Devise
  module Models

    module Auth0Authenticatable
      extend ActiveSupport::Concern

      class MissingAuth0Id < StandardError; end
      class MissingAccount < StandardError; end

      module ClassMethods

        def find_or_sync_auth0(info)
          unless uid = info['user_id']
            raise MissingAuth0Id.new(info),
              "Expected auth0_user_id, got none inside of #{@info.inspect}"
          end

          if user = User.find_by(auth0_user_id: uid)
            # cool
          elsif user = User.find_by(email: info['email'])
            name = user.name || info['name']
            user.update! auth0_user_id: uid, name: name
          else
            user = User.where(email: info['email']).first_or_create
            user.password=Devise.friendly_token
            user.save
            name = user.name || info['name']
            user.update! auth0_user_id: uid, name: name
          end

          user
        end

      end

    end
  end
end

