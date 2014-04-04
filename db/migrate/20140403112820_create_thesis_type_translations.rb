class CreateThesisTypeTranslations < ActiveRecord::Migration
  def up
    Diamond::ThesisType.create_translation_table! name: :string, short_name: :string
  end

  def down
    Diamond::ThesisType.drop_translation_table!
  end
end
