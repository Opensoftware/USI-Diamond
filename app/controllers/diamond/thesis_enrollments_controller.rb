class Diamond::ThesisEnrollmentsController < DiamondController

  authorize_resource :except => [:accept, :reject]

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

    student = Student.where(id: @enrollment.student_id).first
    if student.present?
      @enrollment.save
      if can?(:manage, Diamond::ThesisEnrollment)
        @enrollment.accept!
        if @thesis.can_assign? && @thesis.has_required_students? &&
            can?(:manage_department, @thesis)
          @thesis.assign!
          (@thesis.enrollments - [@enrollment]).each do |enrollment|
            enrollment.reject! if enrollment.can_reject?
          end
        end

        flash[:notice] = t(:label_thesis_enrolled_by_employee, :student => student.surname_name)
      else
        flash[:notice] = t(:label_thesis_enrolled_by_student)
      end
    else
      flash[:error] = t(:label_student_not_found)
    end
    redirect_to thesis_path(params[:thesis_id])
  end

  def accept
    @enrollment = Diamond::ThesisEnrollment.find(params[:id])
    authorize! :update, @enrollment
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
    authorize! :update, @enrollment
    @enrollment.reject! if @enrollment.can_reject?
    redirect_to thesis_path(params[:thesis_id])
  end

  private
  def enrollment_params
    params.require(:thesis_enrollment).permit(:enrollment_type_id, :student_id)
  end

end
