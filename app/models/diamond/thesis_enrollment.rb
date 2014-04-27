class Diamond::ThesisEnrollment < ActiveRecord::Base

  include ::Workflow
  workflow_column :state
  workflow do
    state :pending do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :rejected
    state :accepted
  end

  belongs_to :enrollment_type, :class_name => "Diamond::ThesisEnrollmentType"
  belongs_to :thesis, :class_name => "Diamond::Thesis"
  belongs_to :student, :class_name => "Student"

  scope :primary, -> { joins(:enrollment_type).where("#{Diamond::ThesisEnrollmentType.table_name}.code" => :primary) }
  scope :secondary, -> { joins(:enrollment_type).where("#{Diamond::ThesisEnrollmentType.table_name}.code" => :secondary) }
  scope :accepted , -> { where("#{Diamond::ThesisEnrollment.table_name}.state" => :accepted) }

  def get_studies
    joins(:thesis, :student => :studies).where("#{Diamond::Thesis.table_name}.student_id")
  end

  def primary?
    enrollment_type == Diamond::ThesisEnrollmentType.primary
  end

  def secondary?
    enrollment_type == Diamond::ThesisEnrollmentType.secondary
  end

end
