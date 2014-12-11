class Xlsx::ThesesStatistics < Xlsx::XlsxStub

  attr_reader :supervisors

  def initialize(supervisors)
    super()

    @supervisors = supervisors
  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    annuals = Annual.joins(:theses).uniq.to_a.sort
    thesis_types = Diamond::ThesisType.find(1,2)
    sheet.add_row ["", "", "", I18n.t(:label_annual)], :style => styles[:header]
    sheet.merge_cells("D1:#{Axlsx.col_ref(2 + (annuals.length*thesis_types.length * 3))}1")
    sheet.add_row ["", "", ""] + annuals.collect {|annual| [annual.name] +
    5.times.collect {""} }.flatten, :style => styles[:header]
    start_col = 3
    annuals.each do |annual|
      sheet.merge_cells("#{Axlsx.col_ref(start_col)}2:#{Axlsx.col_ref(start_col + (thesis_types.length * 3) - 1)}2")
      start_col += thesis_types.length * 3
    end
    row = ["", "", ""]
    annuals.each do |annual|
      row += thesis_types.reduce([]) do |sum, thesis_type|
        sum << thesis_type.short_name.downcase
        sum += 2.times.collect { "" }
        sum
      end
    end
    sheet.add_row row, :style => styles[:header]
    start_col = 3
    annuals.each do |annual|
      thesis_types.each do |thesis_type|
        sheet.merge_cells("#{Axlsx.col_ref(start_col)}3:#{Axlsx.col_ref(start_col + 2).chr}3")
        start_col += 3
      end
    end
    header = [I18n.t(:label_title), I18n.t(:label_supervisor_singular),
              I18n.t(:label_department_singular)]
    header += (annuals.length*thesis_types.length).times.reduce([]) do |sum, el|
      sum << I18n.t(:label_thesis_in_total) << I18n.t(:label_thesis_accepted) <<
        I18n.t(:label_thesis_assigned)
      sum
    end
    sheet.add_row header, style: styles[:header_vertical], height: 108

    assigned = ThesesAggregator.new(Diamond::Thesis.assigned
                                    .by_supervisor(supervisors)
                                    .theses_by_supervisor_count)

    accepted = ThesesAggregator.new(Diamond::Thesis.recently_accepted
                                    .by_supervisor(supervisors)
                                    .theses_by_supervisor_count)


    unaccepted = ThesesAggregator.new(Diamond::Thesis
                                      .unaccepted.by_supervisor(supervisors)
                                      .theses_by_supervisor_count)

    supervisors.sort.each do |supervisor|
      row = [supervisor.employee_title.try(:name), supervisor.surname_name.to_s,
             supervisor.department.try(:name)]
      row +=  annuals.reduce([]) do |sum, annual|
        thesis_types.each do |thesis_type|
          sum << unaccepted.get(annual.id, thesis_type.id, supervisor.id) +
            assigned.get(annual.id, thesis_type.id, supervisor.id) +
            accepted.get(annual.id, thesis_type.id, supervisor.id)
          sum << accepted.get(annual.id, thesis_type.id, supervisor.id)
          sum << assigned.get(annual.id, thesis_type.id, supervisor.id)
        end
        sum
      end
      sheet.add_row row
    end
    sheet.column_widths *([14, 23, 23] + 20.times.collect { 5 })
    sheet.add_table "A4:#{Axlsx.col_ref(header.length - 1)}#{supervisors.length+4}", :name => I18n.t(:label_thesis_list)
  end

end
