class CreateThesisTypes < ActiveRecord::Migration
  def change
    create_table :diamond_thesis_types do |t|
      t.string :name
      t.string :short_name
      t.timestamps
    end
  end
end
