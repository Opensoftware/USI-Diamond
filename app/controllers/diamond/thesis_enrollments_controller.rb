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

    result = ::ThesisEnrollment::Create
    .call(thesis: @thesis,
          current_annual: current_annual,
          current_user: current_user,
          enrollment: @enrollment)

    if result.success? && can?(:manage, Diamond::ThesisEnrollment)
      result = ::ThesisEnrollment::AcceptBatch
      .call(thesis: @thesis,
            current_annual: current_annual,
            enrollment: @enrollment,
            message: result.message)
    end

    redirect_to thesis_path(params[:thesis_id]),
      :flash => { (result.success? ? :notice : :error) => t(result.message, result.args)}
  end

  def accept
    @enrollment = Diamond::ThesisEnrollment.find(params[:id])
    authorize! :update, @enrollment
    thesis = Diamond::Thesis.find(params[:thesis_id])

    result = ::ThesisEnrollment::AcceptBatch
    .call(current_annual: current_annual,
          current_user: current_user,
          enrollment: @enrollment,
          thesis: thesis)

    redirect_to thesis_path(params[:thesis_id]),
      :flash => { (result.success? ? :notice : :error) => t(result.message, result.args)}
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
    unless supervisor.thesis_limit_not_exceeded?(current_annual)
      supervisor.deny_remaining_theses!(current_annual)
    end
  end

end
