class Xlsx::ThesesList < Xlsx::XlsxStub

  def initialize(theses)
    super()

    @theses = theses

  end

  protected
  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    sheet.add_row [I18n.t(:label_thesis_singular), I18n.t(:label_department_singular),
      I18n.t(:label_field_of_study_plural), I18n.t(:label_supervisor_singular),
      I18n.t(:label_thesis_degree_candidate), I18n.t(:label_status)], :style => styles[:header]
    @theses.each do |thesis|
      sheet.add_row [thesis.title.to_s, thesis.department.name.to_s,
        thesis.courses.collect{|c| c.name }.join(", ").to_s,
        thesis.supervisor.full_name.to_s,
        thesis.accepted_students.collect{|s| s.surname_name }.join(", ").to_s,
        I18n.t("label_status_#{thesis.state}").to_s]
    end
    sheet.auto_filter = "A1:F#{@theses.length}"
    sheet.column_widths 40

  end

end
