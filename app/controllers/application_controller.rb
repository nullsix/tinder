class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :require_signed_in_user

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !!current_user
  end

  def require_signed_in_user
    unless signed_in?
      redirect_to root_url
    end
  end
end
