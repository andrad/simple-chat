class MessagesController < ApplicationController
  def create
    theme = Theme.find(params[:theme_id])
    message = Message.new(
      message_params.merge!({ theme_id: theme.id, user_id: current_user.id })
    )

    if message.save
      redirect_to theme, notice: 'Message was successfully created.'
    else
      redirect_to theme, error: 'Something went wrong, please review your data.'
    end
  end

  private

  def message_params
    params.require(:message).permit(:message)
  end
end