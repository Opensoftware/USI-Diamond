require 'has_scope'

class Diamond::ThesesController < DiamondController

  has_scope Diamond::Thesis, :by_thesis_type, :as => :thesis_type_id
  has_scope Diamond::Thesis, :by_status, :as => :status
  has_scope Diamond::Thesis, :by_supervisor, :as => :supervisor_id
  has_scope Diamond::Thesis, :by_course, :as => :course_ids
  has_scope Diamond::Thesis, :by_department, :as => :department_id

  respond_to :html, :js

  DEFAULT_FILTERS = {:course => :course_ids, :supervisor => :supervisor_id, :thesis_type => :thesis_type_id, :annual => :annual_id}.freeze

  ALLOWED_ACTIONS = [Diamond::Thesis::ACTION_REJECT, Diamond::Thesis::ACTION_ACCEPT].freeze


  def index
    @theses = apply_scopes(Diamond::Thesis, params)
    .include_peripherals
    .order("lower(title) ASC")
    .paginate(:page => params[:page].to_i < 1 ? 1 : params[:page], :per_page => params[:per_page].to_i < 1 ? 10 : params[:per_page])
    if !current_user || cannot?(:manage, Diamond::Thesis)
      @theses = @theses.visible
    end

    @filters = {}.tap do |h|
      if current_user
        h[:status] = :status
      else
        h[:department] = :department_id
      end
    end
    @filters.merge! DEFAULT_FILTERS

    respond_with @theses do |f|
      f.js { render :layout => false }
    end
  end

  def new
    @thesis = Diamond::Thesis.new
    @courses = current_user.verifable.department.courses.includes(:translations).load.in_groups_of(4, false)
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def create
    @thesis = Diamond::Thesis.new thesis_params

    if action_performed = @thesis.save
      respond_to do |f|
        f.json do
          render :json => {:success => action_performed, :clear => true}.to_json
        end
        f.html do
          redirect_to thesis_path(@thesis)
        end
      end

    else

    end
  end

  def show
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    @primary_enrollments = @thesis.enrollments.primary
    @secondary_enrollments = @thesis.enrollments.secondary
    if !current_user || (current_user && current_user.employee?)
      @enrollment = @thesis.enrollments.build
    else
      @enrollment = current_user.verifable.enrollments.where(thesis_id: @thesis.id).first || @thesis.enrollments.build
    end
    @enrollments_types = Diamond::ThesisEnrollmentType.includes(:translations).load
  end

  def edit
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    @courses = current_user.verifable.department.courses.includes(:translations).load.in_groups_of(4, false)
    @thesis_types = Diamond::ThesisType.includes(:translations).load
  end

  def update
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])

    if @thesis.update(thesis_params)
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
    params.require(:thesis).permit(:title_pl, :title_en, :description, :supervisor_id, :thesis_type_id, :student_amount, :annual_id, :course_ids => [])
  end

  def allowed_action?
    ALLOWED_ACTIONS.include?(params[:perform_action].to_sym)
  end
end