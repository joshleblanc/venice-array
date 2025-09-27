class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  after_action :verify_pundit_authorization

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
