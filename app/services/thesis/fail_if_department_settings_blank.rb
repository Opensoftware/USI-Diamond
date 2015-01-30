class Thesis::FailIfDepartmentSettingsBlank

  include Interactor

  def call
    thesis = context.thesis
    if thesis.supervisor.department.settings_for_annual(thesis.annual).blank?
      context.fail!(message: "error.theses_limit_for_annual_not_present",
            args: {annual: thesis.annual.name})
    end
  end
end
