class CreateThesisEnrollments < ActiveRecord::Migration
  def change
    create_table :diamond_thesis_enrollments do |t|
      t.string :state, :default => :pending
      t.references :thesis, :student, :enrollment_type
      t.timestamps
    end

    add_index(:diamond_thesis_enrollments, [:thesis_id, :student_id], name: 'enrollments_by_thesis_student')
    add_index(:diamond_thesis_enrollments, [:thesis_id], name: 'enrollments_by_thesis')
    add_index(:diamond_thesis_enrollments, [:student_id], name: 'enrollments_by_student')

  end
end
