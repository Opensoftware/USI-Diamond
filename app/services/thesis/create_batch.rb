class Thesis::CreateBatch

  include Interactor::Organizer

  organize Thesis::DenyIfLimitExceeded,
    Thesis::FailIfEnrollmentsNotUnique,
    Thesis::Create,
    Thesis::NotifyThesisSupervisor,
    ThesisEnrollment::AcceptCollection

end
