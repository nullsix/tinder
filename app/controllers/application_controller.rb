class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :require_signed_in_user

  include SessionsHelper
end
