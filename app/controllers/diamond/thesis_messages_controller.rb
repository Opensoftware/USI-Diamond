class Diamond::ThesisMessagesController < DiamondController

  authorize_resource

  def update
    @message = Diamond::ThesisMessage.find(params[:id])
    @message.accept! if @message.can_accept?

    respond_to do |f|
      f.json do
        render :json => {:success => true, :message_id => @message.id}.to_json
      end
    end
  end


end
