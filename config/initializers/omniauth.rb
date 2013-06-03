OmniAuth.config.full_host = ENV['FULL_HOST']

# Rails will have loaded config/initializers/env.sh by now.
# So the environment vars are available for use.
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_API_SECRET'],
    {
      approval_prompt: "auto"
    }
end
