class Thesis::NotifyThesisSupervisor

  include Interactor

  def call

    # If current user is an department admin, notify thesis supervisor he's
    # been assigned to thesis
    if context.can_manage_department_thesis?
      Diamond::ThesesMailer
      .added_thesis(context.current_user.id, context.thesis.id).deliver
    end
  end
end
