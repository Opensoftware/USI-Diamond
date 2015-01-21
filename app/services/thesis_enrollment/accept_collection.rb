class ThesisEnrollment::AcceptCollection

  include Interactor

  def call


    if (pending_enrollments = context.thesis.enrollments.pending).any? &&
        (context.can_manage_own_thesis? ||
         context.can_manage_department_thesis?)

      pending_enrollments.each do |enrollment|
        if !context.thesis.has_required_students? && !enrollment.student.enrolled?
          enrollment.accept!
          # Send new notification if thesis has been assigned to another student.
          if enrollment.previous_changes.try(:[], :student_id)
            Diamond::ThesesMailer.enrollment_accepted(enrollment.id).deliver
          end
        else
          enrollment.reject!
        end
      end
    end
  end
end
