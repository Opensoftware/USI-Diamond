class Diamond::ThesisEnrollmentsController < DiamondController

  def create
    @thesis = Diamond::Thesis.find(params[:thesis_id])
    @enrollment = Diamond::ThesisEnrollment.new enrollment_params
    @enrollment.tap do |e|
      e.thesis_id = params[:thesis_id]
      if can?(:manage, Diamond::ThesisEnrollment)
        e.student_id = params[:thesis_enrollment][:student_id]
      else
        e.student_id = current_user.verifable_id
      end
    end

    @enrollment.save
    if can?(:manage, Diamond::ThesisEnrollment)
      @enrollment.accept!
      @thesis.assign! if @thesis.can_assign? && @thesis.has_required_students?
      student = Student.find(@enrollment.student_id)
      flash[:notice] = t(:label_thesis_enrolled_by_employee, :student => student.surname_name)
    else
      flash[:notice] = t(:label_thesis_enrolled_by_student)
    end
    redirect_to thesis_path(params[:thesis_id])
  end

  def accept
    @enrollment = Diamond::ThesisEnrollment.find(params[:id])
    @enrollment.accept! if @enrollment.can_accept?
    thesis = Diamond::Thesis.find(params[:thesis_id])
    thesis.assign! if thesis.can_assign? && thesis.has_required_students?
    (thesis.enrollments - [@enrollment]) | @enrollment.student.enrollments.to_a.each do |enrollment|
      enrollment.reject! if enrollment.can_reject?
    end
    redirect_to thesis_path(params[:thesis_id]),
    flash: {notice: t(:label_thesis_enrolled_by_employee, student: @enrollment.student.try(:surname_name))}
  end

  def reject
    @enrollment = Diamond::ThesisEnrollment.find(params[:id])
    @enrollment.reject! if @enrollment.can_reject?
    redirect_to thesis_path(params[:thesis_id])
  end

  private
  def enrollment_params
    params.require(:thesis_enrollment).permit(:enrollment_type_id, :student_id)
  end

end
