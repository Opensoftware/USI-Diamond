class DiamondController < ApplicationController

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  def url_options(options={})
    logger.debug "url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

end
