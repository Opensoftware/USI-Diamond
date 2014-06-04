class Xlsx::UnassignedStudents < Xlsx::XlsxStub

  include Xlsx::ThesesHelper

  attr_reader :students

  def initialize(students)
    super()

    @students = students

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    header = [
      I18n.t(:label_thesis_degree_candidate),
      I18n.t(:label_index_number),
      I18n.t(:label_field_of_study_singular),
      I18n.t(:label_study_degree),
      I18n.t(:label_studies_type)
    ]
    sheet.add_row header, :style => styles[:header]
    students.each do |student|
      row = [
        student.surname_name,
        student.index_number
      ]
      row += [:course, :study_degree, :study_type].collect do |param|
        if student.studies.present?
          collection_to_string(student.studies.collect {|st| st.send(param).name } )
        else
          ""
        end
      end
      sheet.add_row row
    end

    sheet.add_table "A1:#{(64 + header.length).chr}#{students.length}",
      :name => I18n.t(:label_thesis_list)
    sheet.column_widths 40, 20, 10, 14

  end
end
