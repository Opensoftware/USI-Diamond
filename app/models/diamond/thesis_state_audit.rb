require_dependency 'diamond/message_generator.rb'

class Diamond::ThesisStateAudit < ActiveRecord::Base

  include Diamond::MessageGenerator

  belongs_to :thesis
  belongs_to :creator, foreign_key: :employee_id, class_name: 'Employee'
  has_many :messages,
    -> { Diamond::ThesisMessage.for_thesis_state },
    :class_name => 'Diamond::ThesisMessage',
    :foreign_key => :audited_id

end
