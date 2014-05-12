class Diamond::ThesesMailer < ActionMailer::Base
  default :from => "autoresponder.szs@agh.edu.pl"

  include Resque::Mailer

  layout 'diamond/default_mailer'

  def new_enrollment(user_id, enrollment_id)
    @enrollment = Diamond::ThesisEnrollment.where(id: enrollment_id).first
    @student = User.where(id: user_id).first.try(:verifable)
    @supervisor = Employee.where(id: @enrollment.thesis.try(:supervisor_id)).first
    mail(:to => @supervisor.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_new_enrollment)}")
  end

  def enrollment_rejected(enrollment_id)
    @enrollment = Diamond::ThesisEnrollment.where(id: enrollment_id).first
    @supervisor = Employee.where(id: @enrollment.thesis.try(:supervisor_id)).first
    mail(:to => @enrollment.student.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_enrollment_rejected)}")
  end

  def enrollment_rejected_timeout(enrollment_id)
    @enrollment = Diamond::ThesisEnrollment.where(id: enrollment_id).first
    @supervisor = Employee.where(id: @enrollment.thesis.try(:supervisor_id)).first
    mail(:to => @enrollment.student.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_enrollment_rejected_timeout)}")
  end

  def enrollment_accepted(enrollment_id)
    @enrollment = Diamond::ThesisEnrollment.where(id: enrollment_id).first
    @supervisor = Employee.where(id: @enrollment.thesis.try(:supervisor_id)).first
    mail(:to => @enrollment.student.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_enrollment_accepted)}")
  end

  def accept_thesis(admin_id, thesis_id)
    @admin = User.where(id: admin_id).first.try(:verifable)
    @thesis = Diamond::Thesis.where(id: thesis_id).first
    mail(:to => @thesis.supervisor.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_thesis_accepted)}")
  end

  def reject_thesis(admin_id, thesis_id)
    @admin = User.where(id: admin_id).first.try(:verifable)
    @thesis = Diamond::Thesis.where(id: thesis_id).first
    mail(:to => @thesis.supervisor.user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_thesis_rejected)}")
  end

end