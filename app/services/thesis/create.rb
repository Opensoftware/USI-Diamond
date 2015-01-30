class Thesis::Create

  include Interactor

  def call

    supervisor = context.thesis.supervisor

    if supervisor.present?
      unless context.thesis.save
        context.fail!(:message => "error_thesis_persistence_failed",
                      :args => { :errors => context.thesis.errors.full_messages } )
      else
        context.message = "label_thesis_added"
        context.args = { :title => context.thesis.title }
      end
    else
      context.fail!(:message => "error_thesis_supervisor_not_given")
    end
  end
end
