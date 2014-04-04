class CreateThesisTranslations < ActiveRecord::Migration

  def up
    Diamond::Thesis.create_translation_table! title: :text, description: :text
  end

  def down
    Diamond::Thesis.drop_translation_table!
  end

end
