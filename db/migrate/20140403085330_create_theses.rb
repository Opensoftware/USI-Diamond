class CreateTheses < ActiveRecord::Migration
  def change
    create_table :diamond_theses do |t|
      t.text :title
      t.text :description
      t.integer :student_amount, :default => 1
      t.string :state, :default => :unaccepted

      t.references :supervisor, :thesis_type, :department, :annual
      t.timestamps
    end
  end
end
