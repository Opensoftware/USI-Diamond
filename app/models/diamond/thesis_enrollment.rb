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
  scope :for_student, ->(student) { where("#{Diamond::ThesisEnrollment.table_name}.student_id" => student) }

  def self.reject_exceeded_enrollments!
    Diamond::ThesisEnrollment.pending.where("created_at < ?",
      Time.zone.now - Settings.enrollment_days_limit.to_i*1.day).each do |enrollment|
      if enrollment.can_reject?
        enrollment.reject!
        Diamond::ThesesMailer.enrollment_rejected_timeout(enrollment.id).deliver
      end
    end
  end

  def get_studies
    joins(:thesis, :student => :studies).where("#{Diamond::Thesis.table_name}.student_id")
  end

  def days_for_acceptance
    ((self.created_at+Settings.enrollment_days_limit.days).to_date - Time.now.to_date).to_i
  end

end
