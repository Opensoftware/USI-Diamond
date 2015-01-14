class ThesisEnrollment::RejectRemainingEnrollments

  include Interactor

  def call

    if context.thesis.assigned?
      ((context.thesis.enrollments - [context.enrollment]) | context.enrollment.student.thesis_enrollments.to_a)
      .each do |enrollment|
        if enrollment.can_reject?
          enrollment.reject!
          Diamond::ThesesMailer.enrollment_rejected(enrollment.id).deliver
        end
      end
    end
  end
end
