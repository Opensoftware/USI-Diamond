class Xlsx::ThesesStatistics::ThesesAggregator

  def initialize(theses)
    @theses = aggregate_theses(theses)
  end

  def get(annual_id, thesis_type_id, supervisor_id)
    @theses[annual_id].try(:[], thesis_type_id).try(:[], supervisor_id).to_i
  end


  private

  def aggregate_theses(theses)
    theses.to_a.reduce({}) do |sum, thesis|
      sum[thesis.annual_id] ||= {}
      sum[thesis.annual_id][thesis.thesis_type_id] ||= {}
      sum[thesis.annual_id][thesis.thesis_type_id][thesis.supervisor_id] = thesis.theses_count
      sum
    end
  end

end
