require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TeachbaseSample
  DOMAIN = case Rails.env
    when 'production' then 'sample.teachbase.tk'
    when 'development' then 'localhost:3000'
    when 'test' then 'test.dev'
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
