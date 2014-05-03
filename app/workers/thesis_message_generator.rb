class ThesisMessageGenerator
  @queue = :msg

  def self.perform(audited_id, klazz, employee_id)

    Diamond::ThesisMessage.create(klazz: klazz, audited_id: audited_id, employee_id: employee_id)
    # TODO create messages for department admins

  end

end
