OmniAuth.config.full_host = ENV['FULL_HOST']

# Rails will have loaded config/initializers/google.rb by now.
# So the constants are available for use.
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_API_SECRET']
end
