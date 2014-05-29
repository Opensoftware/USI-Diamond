class Pdf::PdfStub < Prawn::Document

  def initialize(prawn_opts = {})
    super({:top_margin => 50, :page_size => 'A4'}.merge(prawn_opts))
  end

  def to_pdf

    font_families.update("ClearSans" => {
        :normal => { :file => "#{Rails.root}/app/assets/fonts/ClearSans-Regular-webfont.ttf" },
        :bold => { :file => "#{Rails.root}/app/assets/fonts/ClearSans-Bold-webfont.ttf" }
      })

    font "ClearSans"
    bounding_box [bounds.left, bounds.top + 10], :width  => bounds.width do
      image "#{Rails.root}/app/assets/images/agh_nzw_a_#{I18n.locale || 'pl'}_3w_wbr_rgb_150ppi.jpg", :scale => 0.2
    end

    repeat(2..100) do
      canvas do
        bounding_box [bounds.left + 30, bounds.top - 25], :width  => bounds.width - 60 do
          pdf_title
          stroke_horizontal_rule
        end
      end
    end
    move_down 140

    pdf_content

    string = "<page> / <total>"
    options = { :at => [bounds.right - 150, bounds.bottom - 10],
      :width => 150,
      :align => :right,
      :page_filter => :all,
      :start_count_at => 1}
    number_pages string, options

    render
  end

  protected
  def pdf_content
  end

  def pdf_title
  end

  def bold(text, font_size = 12)
    font "#{Rails.root}/app/assets/fonts/ClearSans-Bold-webfont.ttf" do
      font_size(font_size) { text text }
    end
  end

end
