require_dependency 'diamond/disableable_form_builder'
require 'has_scope'

class Diamond::ThesesController < DiamondController

  has_scope Diamond::Thesis, :by_thesis_type, :as => :thesis_type_id
  has_scope Diamond::Thesis, :by_status, :as => :status
  has_scope Diamond::Thesis, :by_supervisor, :as => :supervisor_id
  has_scope Diamond::Thesis, :by_course, :as => :course_ids
  has_scope Diamond::Thesis, :by_department, :as => :department_id

  respond_to :html, :js

  DEFAULT_FILTERS = {:status => :status, :department => :department_id, :course => :course_ids, :supervisor => :supervisor_id, :thesis_type => :thesis_type_id, :annual => :annual_id}.freeze

  ALLOWED_ACTIONS = [Diamond::Thesis::ACTION_REJECT, Diamond::Thesis::ACTION_ACCEPT].freeze

  helper_method :enrolled?

  def index
    @theses = apply_scopes(Diamond::Thesis, params)
    .include_peripherals
    .order("lower(title) ASC")
    .paginate(:page => params[:page].to_i < 1 ? 1 : params[:page], :per_page => params[:per_page].to_i < 1 ? 10 : params[:per_page])
    if can?(:manage, Diamond::Thesis)
    elsif can?(:manage_own, Diamond::Thesis)
      @theses = @theses.for_supervisor(current_user.verifable_id)
    elsif !current_user || cannot?(:manage, Diamond::Thesis)
      @theses = @theses.visible
    end

    #    @filters = {}.tap do |h|
    #      if current_user && can?(:manage_own, Diamond::Thesis)
    #        h[:status] = :status
    #      else
    #        h[:department] = :department_id
    #      end
    #    end
    @filters = DEFAULT_FILTERS

    respond_with @theses do |f|
      f.js { render :layout => false }
    end
  end

  def new
    @thesis = Diamond::Thesis.new
    2.times { @thesis.enrollments.build }
    @courses = current_user.verifable.academy_unit.courses.includes(:translations).load.in_groups_of(4, false)
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def create
    @thesis = Diamond::Thesis.new thesis_params

    if @thesis.supervisor_id.present?
      @thesis.department_id = @thesis.supervisor.department_id
    end

    if action_performed = @thesis.save
      update_status
      respond_to do |f|
        f.json do
          response = {:success => action_performed, :clear => true}
          with_format(:html) do
            if action_performed
              response[:notice] = render_to_string(partial: 'common/flash_notice_template', locals: {msg: t(:label_thesis_added, title: @thesis.title) } )
            end
          end
          render :json => response.to_json
        end
        f.html do
          redirect_to thesis_path(@thesis)
        end
      end

    else

    end
  end

  def show
    @thesis = Diamond::Thesis.includes(:courses, :enrollments).find(params[:id])
    @student_studies = StudentStudies.joins(:studies, :student => :theses)
    .includes(:studies => [:course => :translations, :study_type => :translations])
    .where("#{StudentStudies.table_name}.student_id IN (?) AND #{Studies.table_name}.course_id IN (?)", @thesis.student_ids, @thesis.course_ids)
    @all_enrollments = @thesis.enrollments.to_a
    if enrolled?
      @enrollments = @thesis.enrollments.accepted
    else
      @enrollments = @thesis.enrollments.accepted
      @enrollments |= @thesis.enrollments.pending if current_user.try(:student?)
      @enrollments |= (@thesis.student_amount - @enrollments.length).times.collect { @thesis.enrollments.build }
    end
  end

  def edit
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    if @thesis.enrollments.blank? && can?(:manage_own, @thesis)
      2.times do
        @thesis.enrollments.build
      end
    end
    @courses = current_user.verifable.academy_unit.courses.includes(:translations).load.in_groups_of(4, false)
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def update
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])

    if @thesis.update(thesis_params)
      update_status
      redirect_to thesis_path(@thesis)
    else
      render 'edit'
    end
  end

  def collection_update
    @theses = Diamond::Thesis
    .include_peripherals.where(:id => params[:thesis_ids])
    @action_performed = true

    Diamond::Thesis.transaction do
      begin
        if params[:perform_action] && allowed_action?
          @theses.each do |thesis|
            action = Diamond::Thesis.const_get("action_#{params[:perform_action]}".upcase)
            thesis.send("#{action}!") if thesis.send("can_#{action}?")
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

    #        @thesis.destroy
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
    @theses = Diamond::Thesis.where(:id => params[:thesis_ids])
    @action_performed = true

    Diamond::Thesis.transaction do
      begin
        #                @theses.destroy_all
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
      :thesis_type_id, :student_amount, :annual_id, :course_ids => []
    ]
    attrs << {:enrollments_attributes => [:id, :student_id, :enrollment_type_id]} if can?(:manage_own, Diamond::Thesis)
    params.require(:thesis).permit(attrs)
  end

  def allowed_action?
    ALLOWED_ACTIONS.include?(params[:perform_action].to_sym)
  end

  def update_status
    if @thesis.enrollments.any? && can?(:manage_own, @thesis)
      @thesis.enrollments.each do |enrollment|
        enrollment.accept! if enrollment.can_accept?
      end
      @thesis.assign! if @thesis.can_assign? && @thesis.enrollments.present? && @thesis.enrollments.all?(&:accepted?)
    end
  end

  def enrolled?
    @thesis.current_state >= :assigned && @thesis.enrollments.length >= @thesis.student_amount
  end

end