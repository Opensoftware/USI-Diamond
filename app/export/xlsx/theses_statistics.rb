class Xlsx::ThesesStatistics < Xlsx::XlsxStub

  attr_reader :supervisors

  def initialize(supervisors)
    super()

    @supervisors = supervisors
  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    annuals = Annual.all
    thesis_types = Diamond::ThesisType.find(1,2)
    sheet.add_row ["", "", "", I18n.t(:label_annual)], :style => styles[:header]
    sheet.merge_cells("D1:#{(67 + (annuals.length*thesis_types.length * 3)).chr}1")
    sheet.add_row ["", "", ""] + annuals.collect {|annual| annual.name},
      :style => styles[:header]
    sheet.merge_cells("D2:#{(67 + (thesis_types.length * 3)).chr}2")
    row = ["", "", ""]
    row += thesis_types.reduce([]) do |sum, thesis_type|
      sum << thesis_type.short_name
      sum += 2.times.collect { "" }
      sum
    end
    sheet.add_row row, :style => styles[:header]
    start_col = 68
    end_col = start_col + 2
    thesis_types.each do |thesis_type|
      sheet.merge_cells("#{start_col.chr}3:#{end_col.chr}3")
      start_col += 3
      end_col = start_col + 2
    end
    header = [I18n.t(:label_title), I18n.t(:label_supervisor_singular),
      I18n.t(:label_department_singular)]
    header += (annuals.length*thesis_types.length).times.reduce([]) do |sum, el|
      sum << I18n.t(:label_thesis_in_total) << I18n.t(:label_thesis_accepted) <<
        I18n.t(:label_thesis_assigned)
      sum
    end
    sheet.add_row header, style: styles[:header_vertical], height: 108
    supervisors.each do |supervisor|
      row = [supervisor.employee_title.try(:name), supervisor.surname_name.to_s,
        supervisor.department.try(:name)]
      row +=  annuals.reduce([]) do |sum, annual|
        thesis_types.each do |thesis_type|
          assigned = Diamond::Thesis.by_thesis_type(thesis_type)
          .by_supervisor(supervisor).assigned.count
          accepted = Diamond::Thesis.by_thesis_type(thesis_type)
          .by_supervisor(supervisor).recently_accepted.count
          sum << Diamond::Thesis.by_supervisor(supervisor).unaccepted.count +
            assigned + accepted
          sum << accepted
          sum << assigned
        end
        sum
      end
      sheet.add_row row
    end
    sheet.column_widths *([14, 23, 23] + 20.times.collect { 5 })
    sheet.add_table "A4:#{(64 + header.length).chr}#{supervisors.length}", :name => I18n.t(:label_thesis_list)
  end

end
