class Xlsx::ThesesList < Xlsx::XlsxStub

  attr_reader :current_user

  def initialize(current_user, theses)
    super()

    @theses = theses
    @current_user = current_user

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    h = header
    sheet.add_row h, :style => styles[:header]
    @theses.each do |thesis|
      sheet.add_row row(thesis)
    end


    sheet.add_table "A1:#{(64 + h.length).chr}#{@theses.length}", :name => I18n.t(:label_thesis_list)
    sheet.column_widths 20, 20, 40

  end

  private

  def header
    if current_user.blank? || current_user.try(:student?)
      [I18n.t(:label_thesis_singular), I18n.t(:label_filter_thesis_type),
        I18n.t(:label_department_singular),
        I18n.t(:label_field_of_study_plural),
        I18n.t(:label_title), I18n.t(:label_supervisor_singular),
        I18n.t(:label_status)]
    elsif current_user.employee?
      [
        I18n.t(:label_thesis_degree_candidate),
        I18n.t(:label_index_number),
        I18n.t(:label_thesis_singular),
        I18n.t(:label_filter_thesis_type),
        I18n.t(:label_field_of_study_singular),
        I18n.t(:label_study_degree),
        I18n.t(:label_studies_type),
        I18n.t(:label_department_singular),
        I18n.t(:label_title), I18n.t(:label_supervisor_singular),
        I18n.t(:label_status)]
    else
      []
    end
  end

  def row(thesis)
    if current_user.blank? || current_user.try(:student?)
      [thesis.title.to_s, thesis.thesis_type.name,
        thesis.courses.collect{|c| c.name }.join(", ").to_s,
        thesis.department.name.to_s,
        thesis.supervisor.employee_title.name,
        thesis.supervisor.surname_name,
        I18n.t("label_status_#{thesis.state}").to_s]
    elsif current_user.employee?
      r = [
        collection_to_string( thesis.accepted_students.collect {|s| s.surname_name }),
        collection_to_string( thesis.accepted_students.collect {|s| s.index_number }),
        thesis.title.to_s,
        thesis.thesis_type.name]
      r += [:course, :study_degree, :study_type].collect do |param|
        if thesis.accepted_students.present?
          collection_to_string(thesis.accepted_students.collect { |s|
              collection_to_string(s.studies.collect {|st| st.send(param).name } ) })
        else
          ""
        end
      end
      r += [
        thesis.department.name.to_s,
        thesis.supervisor.employee_title.name,
        thesis.supervisor.surname_name,
        I18n.t("label_status_#{thesis.state}").to_s]
    else
      []
    end
  end

  def collection_to_string(collection)
    collection.join(", ").to_s
  end
end
