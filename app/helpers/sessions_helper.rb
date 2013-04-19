module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !!current_user
  end

  def require_signed_in_user
    redirect_to(root_url) unless signed_in?
  end

  def owner_is_logged_in?(owning_user)
    current_user && current_user == owning_user
  end
end
