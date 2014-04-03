require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require "diamond"

module Dummy
  class Application < Rails::Application
    config.time_zone = 'Warsaw'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :pl
    config.encoding = "utf-8"
  end
end

