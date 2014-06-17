class Xlsx::XlsxStub

  attr_reader :axlsx, :sheet, :styles

  def initialize
    @axlsx = Axlsx::Package.new
    @sheet = @axlsx.workbook.add_worksheet :page_margins => {:top => 0.5, :bottom => 0.5}
    init_styles(@axlsx.workbook)
  end

  def to_xlsx
    xlsx_content
    axlsx.to_stream.read
  end

  protected
  def xlsx_content
  end

  def xls_title
    I18n.t(:label_thesis_list)
  end

  private
  def init_styles(wb)
    @styles = {}

    @styles[:bold] = wb.styles.add_style :b => true
    @styles[:section_header] = wb.styles.add_style :alignment => { :horizontal => :left, :vertical => :top, :wrap_text => true}, :b => true
    @styles[:header] = wb.styles.add_style :alignment => { :horizontal => :center }, :b => true
    @styles[:font_10] = wb.styles.add_style :sz => 10
    @styles[:wrap_text] = wb.styles.add_style :alignment => { :horizontal => :left,:vertical => :top,:wrap_text => true}
    @styles[:wrap_text_and_border] = wb.styles.add_style :alignment => { :horizontal => :left, :vertical => :top, :wrap_text => true}, :border => { :style => :thin, :color => "00" }
    @styles[:wrap_red_text_and_border] = wb.styles.add_style :alignment => { :horizontal => :left, :vertical => :top, :wrap_text => true}, :border => { :style => :thin, :color => "00" }, :bg_color => "ff0000"
    @styles[:table_section_header] = wb.styles.add_style :alignment => { :horizontal => :left, :vertical => :top, :wrap_text => true}, :border => { :style => :thin, :color => "00" }, :bg_color => "ededed"
    @styles[:thead] = wb.styles.add_style :border => { :style => :thin, :color => "00" }, :bg_color => "bfbfbf"
    @styles[:header_vertical] = wb.styles.add_style :alignment => {:textRotation => 90}, :b => true
  end
end
