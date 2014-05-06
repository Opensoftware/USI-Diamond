class Diamond::ThesisMessage < ActiveRecord::Base

  belongs_to :thesis_enrollment, :foreign_key => :audited_id
  belongs_to :thesis_state_audit, :foreign_key => :audited_id
  belongs_to :user

  include ::Workflow
  workflow_column :state
  workflow do
    state :pending do
      event :accept, :transitions_to => :visited
    end
    state :visited
  end

  scope :for_thesis_state, -> { where(klazz: 'Diamond::ThesisStateAudit') }
  scope :for_enrollment, -> { where(klazz: 'Diamond::ThesisEnrollment') }
  scope :for_employee, ->(employee) { where(user_id: employee) }
  scope :for_department, ->(employee) { joins(:user => :employee).where("#{Employee.table_name}.department_id" => employee.department_id) }
  scope :newest, -> { order("created_at DESC") }

end