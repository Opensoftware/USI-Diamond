class Thesis::FailIfEnrollmentsNotUnique

  include Interactor

  def call

    context.thesis.enrollments.each do |enrollment|
      if enrollment.student.enrolled?
        context.fail!(message: "error.student_already_enrolled",
                      args: {student: enrollment.student.surname_name})
      end
    end
  end
end
