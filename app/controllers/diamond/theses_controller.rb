class Diamond::ThesesController < DiamondController

  def index
    @theses = Diamond::Thesis.includes(:translations)
                             .order("lower(title) ASC").load
  end

  def new
    @thesis = Diamond::Thesis.new
    @courses = current_user.verifable
                           .department
                           .courses
                           .includes(:translations)
                           .load.in_groups_of(4, false)
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
  end

  def edit
    @thesis = Diamond::Thesis.includes(:courses).find(params[:id])
    @courses = current_user.verifable.department
                           .courses.includes(:translations)
                           .load.in_groups_of(4, false)
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

  private
  def thesis_params
    params.require(:thesis).permit(:title_pl, :title_en, :description,
                                   :thesis_type_id, :student_amount,
                                   :annual_id, :course_ids => [])
  end
end
