class Thesis::Create

  include Interactor

  def call

    supervisor = context.thesis.supervisor

    if supervisor.present?
      if supervisor.thesis_limit_not_exceeded?(context.current_annual)
        unless context.thesis.save
          context.fail!(:message => "error_thesis_persistence_failed",
                        :args => { :errors => context.thesis.errors.full_messages } )
        else
          context.message = "label_thesis_added"
          context.args = { :title => context.thesis.title }
        end
      else
        context.fail!(:message => "error_thesis_limit_exceeded",
                      :args => { :limit => supervisor.department
                                 .settings_for_annual(context.current_annual).max_theses_count,
                                 :supervisor => supervisor.surname_name })
      end
    else
      context.fail!(:message => "error_thesis_supervisor_not_given")
    end
  end
end
