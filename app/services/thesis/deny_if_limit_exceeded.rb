class Thesis::DenyIfLimitExceeded

  include Interactor

  def call

    supervisor = context.thesis.supervisor

    unless supervisor.thesis_limit_not_exceeded?(context.current_annual)
      supervisor.deny_remaining_theses!(context.current_annual)

      if context.current_user.employee?
        message = "error.error_thesis_limit_exceeded_supervisor"
      else
        message = "error.error_thesis_limit_exceeded_student"
      end

      context.fail!(
        :message => message,
        :args => {
          :limit => supervisor.department.settings_for_annual(context.current_annual).max_theses_count,
          :supervisor => supervisor.surname_name
      })
    end
  end
end
