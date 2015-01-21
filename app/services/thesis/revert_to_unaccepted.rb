class Thesis::RevertToUnaccepted

  include Interactor

  def call

    # Some changes were made by thesis supervisor and thesis was in published
    # state - need to revert its state to unaccepted
    if context.can_manage_own_thesis? && context.thesis.previous_changes.present? &&
        context.thesis.current_state >= :open && context.thesis.can_revert_to_unaccepted?
      context.thesis.revert_to_unaccepted!
    end
  end
end
