class ThesisEnrollment::AcceptBatch

  include Interactor::Organizer

  organize Thesis::FailIfDepartmentSettingsBlank,
    Thesis::DenyIfLimitExceeded,
    ThesisEnrollment::Accept,
    Thesis::Assign,
    ThesisEnrollment::RejectRemainingEnrollments,
    ThesisEnrollment::RejectStudentEnrollments

end
