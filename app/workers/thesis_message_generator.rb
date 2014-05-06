class ThesisMessageGenerator
  @queue = :msg

  def self.perform(audited_id, klazz, user_id)

    Diamond::ThesisMessage.create(klazz: klazz, audited_id: audited_id, employee_id: User.where(id: user_id).first.try(:verifable_id))
    # TODO create messages for department admins

  end

end
