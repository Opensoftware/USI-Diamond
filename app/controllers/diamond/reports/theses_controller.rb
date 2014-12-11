class Diamond::Reports::ThesesController < DiamondController

  def unassigned_students
    authorize! :manage, :theses_reports

    respond_to do |format|
      format.xlsx do
        students = Student.not_enrolled.includes(:studies => [:course => :translations,
            :study_type => :translations, :study_degree => :translations]).load
        cache_key = fragment_cache_key_for(students)
        data = Rails.cache.fetch(cache_key) do
          file = Xlsx::UnassignedStudents.new(students)
          data = file.to_xlsx
          Rails.cache.write(cache_key, data)
          data
        end
        send_data(data, :filename => "#{t(:label_report_export_unassigned_students_name)}.xlsx", :type => "application/xlsx", :disposition => "inline")
      end
    end
  end


  def supervisors_theses_of_faculty
    authorize! :manage, :theses_reports
    @theses = Diamond::Thesis.by_annual(current_annual)
    .include_peripherals.load
    supervisors_theses("faculty")
  end

  def supervisors_theses_of_department
    authorize! :read, :theses_reports
    @theses = Diamond::Thesis.where(department_id: current_user.verifable.academy_unit_id)
    .include_peripherals.load
    supervisors_theses("department")
  end

  def faculty_theses
    authorize! :manage, :theses_reports
    @theses = Diamond::Thesis.by_annual(current_annual)
    .include_peripherals.includes(:department => :translations,
      :accepted_students => [:studies => [:course => :translations,
          :study_type => :translations, :study_degree => :translations]]).load
    theses
  end

  def department_theses
    authorize! :read, :theses_reports
    @theses = Diamond::Thesis.where(department_id: current_user.verifable.academy_unit_id)
    .include_peripherals.load
    theses
  end

  def supervisor_theses
    authorize! :read, :theses_reports
    @theses = Diamond::Thesis.where(supervisor_id: current_user.verifable_id)
    .include_peripherals.load
    theses
  end

  def faculty_theses_statistics
    authorize! :manage, :theses_reports
    @supervisors = Employee
    .where("department_id IS NOT NULL")
    .includes(:employee_title, :department => :translations)
    theses_statistics
  end

  def department_theses_statistics
    authorize! :read, :theses_reports
    @supervisors = Employee.where(department_id: current_user.verifable.department_id)
    .includes(:employee_title, :department => :translations)
    theses_statistics
  end

  private

  def supervisors_theses(scope)
    respond_to do |format|
      format.xlsx do
        cache_key = fragment_cache_key_for(@theses)
        data = Rails.cache.fetch(cache_key) do
          file = Xlsx::const_get("SupervisorThesesListOf#{scope.camelize(:upper)}")
          .new(current_user, @theses)
          data = file.to_xlsx
          Rails.cache.write(cache_key, data)
          data
        end
        send_data(data, :filename => "#{t("label_report_export_supervisors_theses_of_#{scope}_name")}.xlsx", :type => "application/xlsx", :disposition => "inline")
      end
    end
  end

  def theses
    respond_to do |format|
      format.xlsx do

        cache_key = fragment_cache_key_for(@theses)
        employee_type = params[:action].split("_").first
        data = Rails.cache.fetch(cache_key) do
          file = Xlsx::const_get("#{employee_type.camelize(:upper)}ThesesList")
          .new(current_user, @theses)
          data = file.to_xlsx
          Rails.cache.write(cache_key, data)
          data
        end
        send_data(data, :filename => "#{t("label_report_export_#{employee_type}_theses_name")}.xlsx", :type => "application/xlsx", :disposition => "inline")
      end
    end
  end

  def theses_statistics
    respond_to do |format|
      format.xlsx do

        cache_key = fragment_cache_key_for(@supervisors)
        employee_type = params[:action].split("_").first
        data = Rails.cache.fetch(cache_key) do
          file = Xlsx::const_get("#{employee_type.camelize(:upper)}ThesesStatistics")
          .new(@supervisors)
          data = file.to_xlsx
          Rails.cache.write(cache_key, data)
          data
        end
        send_data(data, :filename => "#{t("label_report_export_#{employee_type}_theses_name")}.xlsx", :type => "application/xlsx", :disposition => "inline")
      end
    end
  end
end
