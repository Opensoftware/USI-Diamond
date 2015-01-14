class Thesis::Assign

  include Interactor

  def call
    if context.thesis.can_assign? && context.thesis.has_required_students?
      context.thesis.assign!
      context.thesis.set_annual!(context.current_annual)
    end
  end
end
