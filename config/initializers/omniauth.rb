OmniAuth.config.full_host = "http://localhost:3000"

# Rails will have loaded config/initializers/google.rb by now.
# So the constants are available for use.
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_CLIENT_ID, GOOGLE_API_SECRET
end
