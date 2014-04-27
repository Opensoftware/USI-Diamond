module Diamond::ThesesHelper

  def thesis_type_label(thesis_record)
    content_tag(:span, :class => "label label-#{thesis_record.thesis_type.short_name.downcase == 'inż' ? 'default' : 'danger'}") do
      thesis_record.thesis_type.short_name.downcase
    end
  end

  def annual_filter_content
    return @annual_filter if defined?(@annual_filter)
    @annual_filter = [[t(:label_all), nil]] | Annual.all.collect {|a| [a.name, a.id]}
  end

  def status_filter_content
    return @status_filter if defined?(@status_filter)
    @status_filter = [[t(:label_all), nil]] | Diamond::Thesis.workflow_spec.states.keys.collect {|w| [state_label(w),w] }
  end

  def course_filter_content
    return @field_of_study_filter if defined?(@field_of_study_filter)
    @field_of_study_filter = [[t(:label_all), nil]] | Course.includes(:translations).load.sort.collect {|a| [a.name, a.id]}
  end

  def supervisor_filter_content
    return @employee_filter if defined?(@employee_filter)
    @employee_filter = [[t(:label_all), nil]] | Employee.having_theses.sort.collect {|a| [a.surname_name_title, a.id]}
  end

  def thesis_type_filter_content
    return @thesis_type_filter if defined?(@thesis_type_filter)
    @thesis_type_filter = [[t(:label_all), nil]] | Diamond::ThesisType.includes(:translations).load.sort.collect {|a| [a.name, a.id]}
  end

  def department_filter_content
    return @department_filter if defined?(@department_filter)
    @department_filter = [[t(:label_all), nil]] | Department.includes(:translations).load.sort.collect {|a| [a.name, a.id]}
  end

  def collection_update_content
    @theses.reduce({}) do |sum, el|
      with_format(:html) do
        sum[el.id] = (params[:status].present? && params[:status] != el.current_state.to_s ? '' : render(:partial => "thesis_record", :locals => {thesis_record: el}))
      end
      sum
    end
  end

  def state_label(current_state)
    I18n.t "label_status_#{current_state}"
  end

  def enrolled?
    @thesis.current_state >= :assigned
  end

  def enrollments_available?
    return @enrollments_available if defined?(@enrollments_available)
    now = Time.now
    @enrollments_available = current_semester.thesis_enrollments_begin <= now && now <= current_semester.thesis_enrollments_end
  end

  def can_enroll?
    (enrollments_available? || can?(:manage, Diamond::Thesis)) && current_user && @thesis.current_state < :assigned && @enrollment.new_record?
  end

  def thesis_record_menu_available?
    current_user && can?(:manage_own, Diamond::Thesis)
  end

  def enrolled_student
    if defined?(@student)
      @student.try(:surname_name)
    elsif current_user.try(:student?)
      current_user.try(:verifable).try(:surname_name)
    end
  end
end
