class Thesis::DenyIfLimitExceeded

  include Interactor

  def call

    supervisor = context.thesis.supervisor

    unless supervisor.thesis_limit_not_exceeded?(context.thesis.annual)
      supervisor.deny_remaining_theses!(context.thesis.annual)

      if context.current_user.employee?
        message = "error.error_thesis_limit_exceeded_supervisor"
      else
        message = "error.error_thesis_limit_exceeded_student"
      end

      context.fail!(
        :message => message,
        :args => {
          :limit => supervisor.department.settings_for_annual(context.thesis.annual).max_theses_count,
          :supervisor => supervisor.surname_name,
          :annual => context.thesis.annual.try(:name)
      })
    end
  end
end
