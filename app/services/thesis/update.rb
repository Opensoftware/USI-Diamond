class Thesis::Update

  include Interactor

  def call

    if context.thesis.update(context.thesis_params)
      context.message = "notice.thesis_updated"
      context.args = { thesis_title: context.thesis.title }
    else
      context.fail!(message: "error.thesis_not_updated",
                    args: { errors: context.thesis.errors.full_messages.join(", ") })
    end
  end
end
