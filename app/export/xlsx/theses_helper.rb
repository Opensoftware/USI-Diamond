module Xlsx::ThesesHelper

  extend ActiveSupport::Concern

  def collection_to_string(collection)
    collection.join(", ").to_s
  end

end
