require 'devise'

module Devise
  module Models

    module Auth0Authenticatable
      extend ActiveSupport::Concern

      class MissingAuth0Id < StandardError; end
      class MissingAccount < StandardError; end

      module ClassMethods

        def find_or_sync_auth0(info)
          uid = info['user_id']

          unless uid.to_s.start_with?('auth0|')
            raise MissingAuth0Id.new(info),
              "Expected auth0_user_id, got none inside of #{@info.inspect}"
          end

          if user = User.find_by(auth0_user_id: uid)
            # cool
          elsif user = User.find_by(email: info['email'])
            name = user.name || info['name']
            user.update! auth0_user_id: uid, name: name
          end

          user
        end

      end

    end
  end
end
