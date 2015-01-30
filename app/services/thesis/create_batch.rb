class Thesis::CreateBatch

  include Interactor::Organizer

  organize Thesis::FailIfDepartmentSettingsBlank,
    Thesis::DenyIfLimitExceeded,
    Thesis::FailIfEnrollmentsNotUnique,
    Thesis::Create,
    Thesis::NotifyThesisSupervisor,
    ThesisEnrollment::AcceptCollection

end
