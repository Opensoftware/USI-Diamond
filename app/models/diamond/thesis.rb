class Diamond::Thesis < ActiveRecord::Base

  ACTION_REJECT = :reject
  ACTION_ACCEPT = :accept

  include ::Workflow

  workflow_column :state
  workflow do
    state :unaccepted do
      event :accept, :transitions_to => :open
      event :reject, :transitions_to => :rejected
      event :assign, :transitions_to => :assigned
    end
    state :rejected do
      event :accept, :transitions_to => :open
    end
    state :open do
      event :reject, :transitions_to => :rejected
      event :assign, :transitions_to => :assigned
    end
    state :assigned do
      event :archive, :transitions_to => :archived
    end
    state :archived
    on_transition do |from, to, triggering_event, *event_args|
      Diamond::ThesisStateAudit.create(:thesis_id => self.id, :state => to, :employee_id => User.current.try(:verifable_id))
    end
  end

  after_create :create_initial_audit

  translates :title, :description
  globalize_accessors :locales => I18n.available_locales

  belongs_to :supervisor, :class_name => "Employee"
  belongs_to :thesis_type
  belongs_to :annual

  has_many :course_thesis, :class_name => "Diamond::CourseThesis", :dependent => :destroy
  has_many :courses, :through => :course_thesis
  has_many :thesis_state_audits, :class_name => "Diamond::ThesisStateAudit", :dependent => :destroy
  has_many :audit_messages, :through => :thesis_state_audits, :source => :messages
  has_many :enrollments, :class_name => "Diamond::ThesisEnrollment", :dependent => :destroy
  accepts_nested_attributes_for :enrollments, :reject_if => lambda { |e|
    e[:student_id].blank?
  }
  has_many :enrollment_messages, :through => :enrollments, :source => :messages
  has_many :students, :through => :enrollments, :dependent => :nullify
  has_many :accepted_students,
  -> { where("#{Diamond::ThesisEnrollment.table_name}.state = ?", :accepted) },
  :through => :enrollments, :dependent => :nullify, :source => :student

  scope :by_thesis_type, ->(tt) { where(:thesis_type_id => tt) }
  scope :by_annual, ->(a) { where(:annual_id => a) }
  scope :by_supervisor, ->(s) { where(:supervisor_id => s) }
  scope :by_course, ->(c) {joins(:courses).where("#{Course.table_name}.id" => c) }
  scope :by_status, ->(s) { where(:state => s) }
  scope :by_department, ->(d) { where(:department_id => d) }
  scope :visible, -> { where(:state => [:open, :archived, :assigned]) }
  scope :for_supervisor, ->(s) { where("state IN (?) OR supervisor_id = ?", [:open, :archived, :assigned], s) }
  scope :recently_accepted, -> { where(:state => :open) }
  scope :recently_updated, -> { order("updated_at DESC") }
  scope :recently_created, -> { newest }
  scope :unaccepted, -> { where(:state => [:unaccepted, :rejected]) }
  scope :newest_enrollments, -> { joins(:enrollments).order("#{Diamond::ThesisEnrollment.table_name}.created_at DESC") }
  scope :newest, -> { order("created_at DESC") }
  scope :pick_five, -> { limit(5) }

  def self.include_peripherals
    includes(:translations, :annual, [:supervisor => :employee_title], [:thesis_type => :translations], [:courses => :translations])
  end

  def assigned_to_course?(course)
    courses.include?(course)
  end

  def enrollments_count
    enrollments.count
  end

  def assigned?
    current_state  >= :assigned
  end

  def has_required_students?
    enrollments.accepted.length >= student_amount
  end

  private
  def create_initial_audit
    Diamond::ThesisStateAudit.create(:thesis_id => self.id, :state => :unaccepted, :employee_id => User.current.try(:verifable_id))
    true
  end

end
