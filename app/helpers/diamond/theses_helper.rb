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
    manage_states = [].tap do |s|
      s << :unaccepted  if cannot?(:manage_own, Diamond::Thesis)
      s << :rejected  if cannot?(:manage, Diamond::Thesis)
    end
    @status_filter = [[t(:label_all), nil]] | (Diamond::Thesis.workflow_spec.states.keys - manage_states).collect {|w| [state_label(w),w] }
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

  def enrollments_available?
    return @enrollments_available if defined?(@enrollments_available)
    now = Time.now
    @enrollments_available = current_semester.thesis_enrollments_begin <= now && now <= current_semester.thesis_enrollments_end
  end

  def can_enroll?(enrollment)
    @can_enrollments = {} unless defined?(@can_enrollments)
    return @can_enrollments[enrollment] if @can_enrollments.has_key?(enrollment)
    @can_enrollments[enrollment] = (enrollments_available? || can?(:manage, Diamond::Thesis)) && current_user.present? &&
    @thesis.try(:current_state) < :assigned &&
    enrollment.new_record?
    @can_enrollments[enrollment] = current_user.try(:student?) ? @can_enrollments[enrollment] && !current_user.verifable.enrolled_for_thesis?(@thesis) : @can_enrollments[enrollment]
  end

  def enrollment_accepted?(enrollment)
    enrollment.current_state == :accepted
  end

  def thesis_record_menu_available?
    current_user && can?(:manage_own, Diamond::Thesis)
  end

  def disableable?(enrollment)
    if current_user.try(:student?)
      true
    else
      !can_enroll?(enrollment)# ? {} : {:disabled => true}
    end
  end

  def can_edit?(thesis)
    @can_edit = {} unless defined?(@can_edit)
    return @can_edit[thesis] if @can_edit.has_key?(thesis)
    @can_edit[thesis] = thesis.new_record? ||
    ((can?(:manage_own, thesis) && thesis.try(:current_state) < :open) ||
      (can?(:manage, thesis)))
  end

  def format_status(status)
    color = case status.to_s
    when 'accepted' then
      'text-success'
    when 'rejected' then
      'text-danger'
    else
      ''
    end
    content_tag(:span, :class => color) do
      I18n.t "label_status_#{status}"
    end
  end
end
