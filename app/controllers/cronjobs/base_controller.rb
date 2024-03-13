require 'google/cloud/resource_manager'

module Cronjobs
  class BaseController < ActionController::Base
    rescue_from Exception, with: :handle_error_log

    private

    # Always remember to call verify_oidc_token! for every actions of this controller
    def verify_oidc_token!(action_path)
      return if Rails.env.development?

      # Google::Auth::IDTokens#verify_oidc will raise an error if it failed to
      # verify the token with Google certs. Details here
      # https://github.com/googleapis/google-auth-library-ruby/blob/googleauth/v0.17.1/lib/googleauth/id_tokens.rb#L155-L191
      payload = authenticate_with_http_token do |oidc_token|
        Google::Auth::IDTokens.verify_oidc(oidc_token, aud: action_path)
      end

      raise 'Missing OIDC token in the Authorization header' unless payload

      verify_service_account_permission!(payload['email'])

      payload
    end

    # Verify if the service account used to generate the OIDC token
    # has enough permissions to invoke this Cloud Run service.
    def verify_service_account_permission!(email)
      service_account = "serviceAccount:#{email}"
      resource_manager = Google::Cloud::ResourceManager.new
      project = resource_manager.project ENV.fetch('GCP_PROJECT_ID')
      policy = project.policy
      required_role = 'roles/run.invoker'

      raise "Missing #{required_role} on #{service_account}" if policy.roles.fetch(required_role, []).exclude?(service_account)
    end

    def handle_error_log(error)
      raise error if Rails.env.development?

      Google::Cloud::ErrorReporting.report(error)
      raise error
    end
  end
end
