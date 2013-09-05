# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
end

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch('spec/support/')
  watch(%r{^spec/support/(.+)\.rb$}) { :rspec } # Watch support files to see if rspec needs to be reloaded
  watch(%r{features/support/}) { :cucumber }
  watch(%r{^spec/factories/.+\.rb}) { :rspec }
end

guard 'rspec', all_after_pass: false, cli: '--drb' do

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" } # Watch support files to see if specs need to be re-run
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch(%r{^spec/factories/(.+)\.rb$})                { |m| "spec/models/#{m[1]}_spec.rb" }

  # Capybara feature specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| ["spec/features/#{m[1]}_spec.rb", "spec/features/#{m[1]}_management_spec.rb"] }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }

  # Lib directory
  #watch(%r{^spec/lib/(.+)\._spec\.rb$})
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end
