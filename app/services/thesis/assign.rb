class Thesis::Assign

  include Interactor

  def call
    if ((context.can_manage_department_thesis?) ||
      (context.can_manage_own_thesis? && context.thesis.open?)) &&
        context.thesis.can_assign? &&
        context.thesis.has_required_students?
      context.thesis.assign!
      context.thesis.set_annual!(context.current_annual)
    end
  end
end
