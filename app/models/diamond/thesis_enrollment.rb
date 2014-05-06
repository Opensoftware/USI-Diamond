require_dependency 'diamond/message_generator.rb'

class Diamond::ThesisEnrollment < ActiveRecord::Base

  include Diamond::MessageGenerator
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
  has_many :messages, -> { Diamond::ThesisMessage.for_enrollment },
    :class_name => 'Diamond::ThesisMessage',
    :foreign_key => :audited_id,
    :dependent => :destroy

  scope :accepted, -> { where("#{Diamond::ThesisEnrollment.table_name}.state" => :accepted) }
  scope :pending, -> { where("#{Diamond::ThesisEnrollment.table_name}.state" => :pending) }

  def get_studies
    joins(:thesis, :student => :studies).where("#{Diamond::Thesis.table_name}.student_id")
  end

end
