require_dependency 'disableable_form_builder'
require 'has_scope'

class Diamond::ThesesController < DiamondController

  has_scope Diamond::Thesis, :by_thesis_type, :as => :thesis_type_id
  has_scope Diamond::Thesis, :by_status, :as => :status
  has_scope Diamond::Thesis, :by_supervisor, :as => :supervisor_id
  has_scope Diamond::Thesis, :by_course, :as => :course_ids
  has_scope Diamond::Thesis, :by_department, :as => :department_id
  has_scope Diamond::Thesis, :by_annual, :as => :annual_id

  respond_to :html, :js, :json

  DEFAULT_FILTERS = {:status => :status, :department => :department_id, :course => :course_ids, :supervisor => :supervisor_id, :thesis_type => :thesis_type_id, :annual => :annual_id}.freeze

  ALLOWED_ACTIONS = [Diamond::Thesis::ACTION_REJECT, Diamond::Thesis::ACTION_ACCEPT].freeze

  helper_method :enrolled?

  authorize_resource :except => [:index, :accept, :revert_to_open,
                                 :collection_update, :change_history, :collection_destroy]
  skip_authorization_check :only => [:index]

  def index
    set_thesis_annual_default!
    @theses = apply_scopes(Diamond::Thesis, params)
    .order("lower(title) ASC")
    if can?(:manage_department, Diamond::Thesis)
    elsif can?(:manage_own, Diamond::Thesis)
      @theses = @theses.for_supervisor(current_user.verifable_id)
    elsif !current_user || cannot?(:manage, Diamond::Thesis)
      @theses = @theses.visible
    end

    @filters = DEFAULT_FILTERS

    if exportable_format?
      @cache_key = fragment_cache_key_for(@theses)
      @theses = @theses.include_peripherals
      .includes(:department => :translations,
                :accepted_students => [:studies => [:course => :translations,
                                                    :study_type => :translations, :study_degree => :translations]])
    else
      @theses = @theses.include_peripherals.paginate(:page => params[:page].to_i < 1 ? 1 : params[:page],
                                                     :per_page => params[:per_page].to_i < 1 ? 10 : params[:per_page])
    end
    respond_with @theses do |f|
      f.js { render :layout => false }
      [:xlsx, :pdf].each do |format|
        f.send(format) do
          data = Rails.cache.fetch(@cache_key) do
            file = format.to_s.classify.constantize::ThesesList.new(current_user, @theses)
            data = file.send("to_#{format}")
            Rails.cache.write(@cache_key, data)
            data
          end

          send_data(data, :filename => "#{t(:label_thesis_list)}.#{format}", :type => "application/#{format}", :disposition => "inline")
        end
      end
    end
  end

  def new
    @thesis = Diamond::Thesis.new
    thesis_preload
    if @courses.blank? && cannot?(:manage, Diamond::Thesis)
      flash[:error] = t(:error_employee_department_blank,
                        employee: current_user.verifable.surname_name)
      redirect_to diamond.theses_path
    end
  end

  def create
    @thesis = Diamond::Thesis.new(thesis_params).tap do |t|
      if can?(:manage, Diamond::Thesis) && t.supervisor_id.present?
        # If current_user is an admin, assign thesis to supervisor department
        t.department_id = t.supervisor.department_id
      elsif can?(:manage_department, Diamond::Thesis)
        # If current_user is a department admin, assign thesis to his department
        t.department_id = current_user.verifable.department_id
      end
    end

    result = ::Thesis::CreateBatch
    .call(thesis: @thesis,
          current_annual: current_annual,
          current_user: current_user,
          can_manage_own_thesis?: can?(:manage_own, @thesis),
          can_manage_department_thesis?: can?(:manage_department, @thesis))

    respond_to do |f|
      f.json do
        @result = result
        @response = {:success => result.success?, :clear => @thesis.persisted?}
        render :layout => false
      end
      f.html do
        if result.success?
          redirect_to thesis_path(result.thesis),
            :flash => {:notice => t(result.message, result.args)}
        else
          flash.now[:error] = t(result.message, result.args)
          thesis_preload
          render action: :new
        end
      end
    end
  end

  def show
    @thesis = Diamond::Thesis.includes(:courses, :enrollments).find(params[:id])
    @student_studies = StudentStudies.joins(:studies, :student => :theses)
    .includes(:studies => [:course => :translations, :study_type => :translations])
    .where("#{StudentStudies.table_name}.student_id IN (?) AND #{Studies.table_name}.course_id IN (?)",
           @thesis.student_ids, @thesis.course_ids)
    @all_enrollments = @thesis.enrollments.to_a
    if enrolled?
      @enrollments = @thesis.enrollments.accepted
    else
      @enrollments = @thesis.enrollments.accepted
      @enrollments |= @thesis.enrollments.pending.for_student(current_user.verifable) if current_user.try(:student?)
      @enrollments |= (@thesis.student_amount - @enrollments.length).times
      .collect { @thesis.enrollments.build }
    end
  end

  def edit
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    authorize! :update, @thesis
    thesis_preload
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def update
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    authorize! :update, @thesis

    result = ::Thesis::UpdateBatch
    .call(current_user: current_user,
          current_annual: current_annual,
          thesis: @thesis,
          can_manage_own_thesis?: can?(:manage_own, @thesis),
          can_manage_department_thesis?: can?(:manage_department, @thesis),
          thesis_params: thesis_params)

    if result.success?
      redirect_to thesis_path(@thesis)
    else
      thesis_preload
      render 'edit'
    end
  end

  def accept
    @thesis = Diamond::Thesis.include_peripherals.find(params[:id])
    authorize! :update, @thesis

    if @thesis.has_required_students?
      @thesis.assign! if @thesis.can_assign?
    elsif @thesis.can_accept?
      @thesis.accept!
      Diamond::ThesesMailer.accept_thesis(current_user.id, @thesis.id).deliver
    end

    respond_with @thesis do |f|
      f.json do
        @action_performed = true
        render :layout => false
      end
    end
  end

  def revert_to_open
    @thesis = Diamond::Thesis.include_peripherals.find(params[:id])
    authorize! :update, @thesis

    if @thesis.can_revert_to_open?
      @thesis.revert_to_open!
      @thesis.enrollments.destroy_all
      Diamond::ThesesMailer.revert_to_open_thesis(current_user.id, @thesis.id).deliver
    end

    respond_with @thesis do |f|
      f.json do
        @action_performed = true
        render :layout => false
      end
    end
  end

  def collection_revert_to_open
    authorize! :update, Diamond::Thesis

    Diamond::Thesis.denied.each do |thesis|
      thesis.revert_to_open!
      thesis.enrollments.destroy_all
    end


    redirect_to main_app.edit_setting_path(current_settings)
  end

  def change_history
    @thesis = Diamond::Thesis.find(params[:id])
    authorize! :read, @thesis
  end

  def collection_update
    @theses = Diamond::Thesis
    .include_peripherals.where(:id => params[:thesis_ids])
    authorize! :update, Diamond::Thesis
    @action_performed = true

    Diamond::Thesis.transaction do
      begin
        if params[:perform_action] && allowed_action?
          @theses.each do |thesis|
            action = Diamond::Thesis.const_get("action_#{params[:perform_action]}".upcase)
            thesis.send("#{action}!") if thesis.send("can_#{action}?")
            Diamond::ThesesMailer.send("#{action}_thesis", current_user.id, thesis.id).deliver
          end
        end
      rescue
        @action_performed = false
        raise ActiveRecord::Rollback
      end
    end
    respond_with @theses do |f|
      f.json do
        render :layout => false
      end
    end
  end

  def destroy
    @thesis = Diamond::Thesis.find(params[:id])
    authorize! :destroy, @thesis

    @thesis.destroy
    respond_with @thesis do |f|
      f.html do
        redirect_to theses_path
      end
      f.js do
        render :layout => false
      end
    end
  end

  def collection_destroy
    authorize! :destroy, Diamond::Thesis
    @theses = Diamond::Thesis.where(:id => params[:thesis_ids])
    @action_performed = true

    Diamond::Thesis.transaction do
      begin
        @theses.destroy_all
        @thesis_ids = params[:thesis_ids]
      rescue
        @action_performed = false
        raise ActiveRecord::Rollback
      end
    end
    respond_with @theses do |f|
      f.json do
        render :layout => false
      end
    end
  end

  private
  def thesis_params
    attrs = [:title_pl, :title_en, :description, :supervisor_id,
             :thesis_type_id, :student_amount, :annual_id, :department_id,
             :course_ids => []
             ]
    if can?(:manage_own, Diamond::Thesis) || can?(:manage_department, Diamond::Thesis)
      attrs << {:enrollments_attributes => [:id, :student_id, :enrollment_type_id]}
    end
    params.require(:thesis).permit(attrs)
  end

  def allowed_action?
    ALLOWED_ACTIONS.include?(params[:perform_action].to_sym)
  end

  def enrolled?
    @thesis.current_state >= :assigned && @thesis.enrollments.accepted.length >= @thesis.student_amount
  end

  def thesis_preload
    2.times { @thesis.enrollments.build } if @thesis.current_state < :assigned
    if current_user.verifable.department.present?
      @courses = current_user.verifable.department.faculty.courses
    elsif can?(:manage, Diamond::Thesis) && current_user.verifable.academy_unit_id.present?
      if current_user.verifable.academy_unit.kind_of_faculty?
        @courses = current_user.verifable.academy_unit.courses
      end
    end
    if @courses
      @courses = @courses.includes(:translations).load.in_groups_of(4, false)
    end
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def set_thesis_annual_default!
    params[:annual_id] ||= current_annual.try(:id)
  end

end
