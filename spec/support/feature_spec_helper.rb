module FeatureSpecHelper
  def login_with_oauth(service = :google_oauth2)
    visit "/auth/#{service}"
  end

  def logout
    click_link "Sign Out"
  end
end
