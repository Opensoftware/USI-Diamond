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
            (can?(:manage_department, @thesis) ||
              (@thesis.current_state >= :open && can?(:manage_own, @thesis)))
          @thesis.assign!
          (@thesis.enrollments - [@enrollment]).each do |enrollment|
            enrollment.reject! if enrollment.can_reject?
          end
        end
        flash[:notice] = t(:label_thesis_enrolled_by_employee, :student => student.surname_name)
      else
        Diamond::ThesesMailer.new_enrollment(current_user.id, @enrollment.id).deliver
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
    if @enrollment.can_accept?
      @enrollment.accept!
      Diamond::ThesesMailer.enrollment_accepted(@enrollment.id).deliver
    end
    thesis = Diamond::Thesis.find(params[:thesis_id])
    thesis.assign! if thesis.can_assign? && thesis.has_required_students?
    ((thesis.enrollments - [@enrollment]) | @enrollment.student.enrollments.to_a).each do |enrollment|
      if enrollment.can_reject?
        enrollment.reject!
        Diamond::ThesesMailer.enrollment_rejected(enrollment.id).deliver
      end
    end
    deny_theses(thesis.supervisor)
    redirect_to thesis_path(params[:thesis_id]),
      flash: {notice: t(:label_thesis_enrolled_by_employee, student: @enrollment.student.try(:surname_name))}
  end

  def reject
    @enrollment = Diamond::ThesisEnrollment.find(params[:id])
    authorize! :update, @enrollment
    if @enrollment.can_reject?
      @enrollment.reject!
      Diamond::ThesesMailer.enrollment_rejected(@enrollment.id).deliver
    end
    deny_theses(@enrollment.thesis.supervisor)
    redirect_to thesis_path(params[:thesis_id])
  end

  private
  def enrollment_params
    params.require(:thesis_enrollment).permit(:enrollment_type_id, :student_id)
  end

  def deny_theses(supervisor)
    unless supervisor.thesis_limit_not_exceeded?
      supervisor.deny_remaining_theses!
    end
  end

end
