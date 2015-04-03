class MessageSocket
  def initialize app
    @app = app
  end

  def call env
    @env = env
    if socket_request?
      socket = spawn_socket
      socket.rack_response
    else
      @app.call env
    end
  end

  private

  attr_reader :env

  def spawn_socket
    socket = Faye::WebSocket.new env

    socket.on :open do
      socket.send 'Hello'
    end

    socket.on :message do |event|
      socket.send event.data
      begin
        tokens = event.data.split("\n")
        operation = tokens.delete_at 0

        case operation
        when 'message'
          message socket, tokens
        end
      rescue Exception => e
        p e
        p e.backtrace
      end
    end

    socket
  end

  def message socket, tokens
    message = Message.new(
      user_id: tokens[0],
      theme_id: tokens[1],
      message: tokens[2],
    )

    if message.save
      response = <<HTML
<p><strong>#{message.created_at} [#{message.user.email}]: </strong>#{message.message}</p>
HTML
      socket.send "messageok\n#{response}"
    else
      socket.send 'messagefail'
    end
  end

  def socket_request?
    Faye::WebSocket.websocket? env
  end
end