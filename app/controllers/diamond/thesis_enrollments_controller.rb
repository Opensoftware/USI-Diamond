class Diamond::ThesisEnrollmentsController < DiamondController

  def create
    @enrollment = Diamond::ThesisEnrollment.new enrollment_params
    @enrollment.thesis_id = params[:thesis_id]
    @enrollment.student_id = can?(:manage, Diamond::ThesisEnrollment) ? params[:thesis_enrollment][:student_id] : current_user.verifable_id
    if @enrollment.save
      @enrollment.accept!
      redirect_to thesis_path(params[:thesis_id]), flash: {notice: 'ble bls'}
    end
  end

  private
  def enrollment_params
    params.require(:thesis_enrollment).permit(:enrollment_type_id, :student_id)
  end

end
