class Thesis::UpdateBatch

  include Interactor::Organizer

  organize Thesis::FailIfDepartmentSettingsBlank,
    Thesis::DenyIfLimitExceeded,
    Thesis::FailIfEnrollmentsNotUnique,
    Thesis::Update,
    Thesis::RevertToUnaccepted,
    Thesis::NotifyThesisSupervisor,
    ThesisEnrollment::AcceptCollection,
    Thesis::Assign

end
