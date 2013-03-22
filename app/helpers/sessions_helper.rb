module SessionsHelper
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

  def owner_is_logged_in?(owning_user)
    current_user && current_user == owning_user
  end
end
