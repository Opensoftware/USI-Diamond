class CreateThesisStateAudits < ActiveRecord::Migration
  def change
    create_table :diamond_thesis_state_audits do |t|
      t.references :thesis, :employee
      t.string :state

      t.timestamps
    end

    add_index(:diamond_thesis_state_audits, [:thesis_id, :employee_id], name: 'by_thesis_employee')
    add_index(:diamond_thesis_state_audits, [:thesis_id], name: 'audits_by_thesis')
  end
end
