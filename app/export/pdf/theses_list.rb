class Pdf::ThesesList < Pdf::PdfStub

  def initialize(kontroller, theses)
    super(kontroller, :page_layout => :landscape)

    @theses = theses
  end

  protected
  def pdf_content

    t = []
    t_header = [I18n.t(:label_thesis_singular), I18n.t(:label_department_singular),
      I18n.t(:label_field_of_study_plural), I18n.t(:label_supervisor_singular),
      I18n.t(:label_thesis_degree_candidate), I18n.t(:label_status)]
    t << t_header
    @theses.each do |thesis|
      t << [thesis.title, thesis.department.name,
        thesis.courses.collect{|c| c.name }.join(", "),
        thesis.supervisor.full_name,
        thesis.accepted_students.collect{|s| s.surname_name }.join(", "),
        I18n.t("label_status_#{thesis.state}")]
    end

    bold I18n.t(:label_thesis_list), 10
    table(t, :width => bounds.width) do
      cells.style( :size => 9)
      row(0).background_color = "cdcdcd"

      columns(0).width = 265
      columns(4).width = 80
    end
  end

  def pdf_title
    text I18n.t(:label_thesis_list), :align => :left, :size => 10
  end
end
