class ThesisMessageGenerator
  @queue = :msg

  def self.perform(audited_id, klazz, auditor_id, thesis_id)

    auditor = User.where(id: auditor_id).first
    ability = Ability.new(auditor)
    thesis = Diamond::Thesis.where(id: thesis_id).first

    if auditor
      recipients = [].let do |t|
        if auditor.employee?
          # Add auditor_id (sender) to recipients if he is thesis supervisor
          # or a department admin
          t << auditor_id if ability.can?(:manage_own, thesis) || ability.can?(:manage_department, thesis)
          # Add thesis supervisor to recipients if auditor_id (sender) is
          # a department admin
          t << thesis.supervisor.user.id if ability.can?(:manage_department, thesis)
        else # Auditor is a student
          # Notify supervisor
          t << thesis.supervisor.user.id
          # Notify department admins
          t |= User.joins(:employee)
          .where("#{Employee.table_name}.department_id = ? AND #{User.table_name}.role_id = ?",
            thesis.department_id, Role.where(const_name: :department_admin).first)
          .pluck("#{User.table_name}.id")
        end
        t
      end

      recipients.uniq.each do |r|
        Diamond::ThesisMessage.create(klazz: klazz, audited_id: audited_id,
          auditor_id: auditor.try(:verifable_id),
          recipient_id: r)
      end

    end

  end

end
