class ThesisEnrollment::AcceptBatch

  include Interactor::Organizer

  organize Thesis::DenyIfLimitExceeded,
    ThesisEnrollment::Accept,
    Thesis::Assign,
    ThesisEnrollment::RejectRemainingEnrollments,
    ThesisEnrollment::RejectStudentEnrollments

end
