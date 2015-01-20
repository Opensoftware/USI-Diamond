class ThesisEnrollment::RejectStudentEnrollments

  include Interactor

  def call
    student = context.enrollment.student

    # Reject all remaining (pending) student enrollments if he's already
    # enrolled for enough amount of theses.
    if student.enrolled?
      student.thesis_enrollments.pending.each do |thesis_enrollment|
        thesis_enrollment.reject!
      end
    end
  end
end
