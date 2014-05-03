class CreateThesisMessages < ActiveRecord::Migration
  def change
    create_table :diamond_thesis_messages do |t|
      t.references :audited, :employee
      t.string :klazz
      t.string :state, :default => :pending
      t.timestamps
    end

    add_index :diamond_thesis_messages, [:klazz, :audited_id], name: 'diamond_thesis_messages_by_klazz_audited_id'
    add_index :diamond_thesis_messages, [:klazz, :employee_id], name: 'diamond_thesis_messages_by_klazz_employee_id'
  end
end
