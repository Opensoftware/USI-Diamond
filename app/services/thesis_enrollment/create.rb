class ThesisEnrollment::Create

  include Interactor

  def call

    student = context.enrollment.student
    if student.present?
      unless student.enrolled?
        context.enrollment.save
        if context.current_user.student?
          Diamond::ThesesMailer.new_enrollment(context.current_user.id, context.enrollment.id).deliver
          context.message = "label_thesis_enrolled_by_student"
        else
          context.message = "label_thesis_enrolled_by_employee"
        end
      else
        context.fail!(message: "error.student_already_enrolled",
                      args: { student: student.surname_name })
      end
    else
      context.fail!(message: "label_student_not_found")
    end
  end
end
