class ThesisEnrollment::Accept

  include Interactor

  def call
    if context.enrollment.can_accept?
      context.enrollment.accept!
      Diamond::ThesesMailer.enrollment_accepted(context.enrollment.id).deliver
      context.message = "label_thesis_enrolled_by_employee"
      context.args = {student: context.enrollment.student.surname_name}
    end
  end
end
