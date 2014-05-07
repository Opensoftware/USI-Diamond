class CreateThesisMessages < ActiveRecord::Migration
  def change
    create_table :diamond_thesis_messages do |t|
      t.references :audited, :auditor, :recipient
      t.string :klazz
      t.string :state, :default => :pending
      t.timestamps
    end

    add_index :diamond_thesis_messages, [:klazz, :audited_id], name: 'diamond_thesis_messages_by_klazz_audited_id'
    add_index :diamond_thesis_messages, [:klazz, :auditor_id], name: 'diamond_thesis_messages_by_klazz_auditor_id'
    add_index :diamond_thesis_messages, [:klazz, :recipient_id], name: 'diamond_thesis_messages_by_klazz_recipient_id'
  end
end
