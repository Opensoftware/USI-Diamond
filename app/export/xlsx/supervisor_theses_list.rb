class Xlsx::SupervisorThesesList < Xlsx::XlsxStub

  include Xlsx::ThesesHelper

  attr_reader :theses

  def initialize(current_user, theses)
    super()

    @theses = theses

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    header = [I18n.t(:label_thesis_singular), I18n.t(:label_filter_thesis_type),
      I18n.t(:label_filter_annual),
      I18n.t(:label_title), I18n.t(:label_supervisor_singular),
      I18n.t(:label_department_singular),
      I18n.t(:label_thesis_degree_candidate),
      I18n.t(:label_index_number),
      I18n.t(:label_status)
    ]
    sheet.add_row header, :style => styles[:header]
    theses.each do |thesis|
      sheet.add_row [
        thesis.title.to_s, thesis.thesis_type.name,
        thesis.annual.name,
        thesis.supervisor.employee_title.name,
        thesis.supervisor.surname_name,
        thesis.department.name.to_s,
        collection_to_string( thesis.accepted_students.collect {|s| s.surname_name }),
        collection_to_string( thesis.accepted_students.collect {|s| s.index_number }),
        I18n.t("label_status_#{thesis.state}").to_s
      ]
    end

    sheet.add_table "A1:#{(64 + header.length).chr}#{theses.length}",
      :name => I18n.t(:label_thesis_list)
    sheet.column_widths 40, 20, 10, 14

  end

end
