module JwtSecured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    rescue_from JWT::VerificationError, JWT::DecodeError, with: :render_jwt_unauthorized
  end

  private

  # raises JWT::VerificationError if an Authorization header JWT is not present or not valid
  # by default, that exception renders :unauthorized
  # sets @authz_jwt with the decoded JWT or the mock token
  def authenticate_request!
    @authz_jwt ||= begin
      if mock_token.present?
        JSON.parse(mock_token).with_indifferent_access
      else
        payload, header = JWT.decode(authz_bearer_value, nil, false)
        payload.with_indifferent_access
      end
    end
  end

  def authz_bearer_value
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(/\s+/).drop(1).join(' ')
    end
  end

  def mock_token
    authz_bearer_value if (authz_bearer_value.presence || '').starts_with?('{')
  end

  def render_jwt_unauthorized
    logger.warn "JWT unauthorized. Bearer = #{authz_bearer_value}"
    head :unauthorized
  end

end
