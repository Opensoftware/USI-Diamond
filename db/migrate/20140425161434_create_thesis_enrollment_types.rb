class CreateThesisEnrollmentTypes < ActiveRecord::Migration
  def up
    create_table :diamond_thesis_enrollment_types do |t|
      t.string :name
      t.string :code
      t.timestamps
    end

    Diamond::ThesisEnrollmentType.create_translation_table! :name => :string
  end

  def down
    Diamond::ThesisEnrollmentType.drop_translation_table!
    drop_table :diamond_thesis_enrollment_types
  end
end
