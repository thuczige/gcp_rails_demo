module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :render_internal_error
  end

  def render_internal_error(error)
    Google::Cloud::ErrorReporting.report(error)
  end
end
