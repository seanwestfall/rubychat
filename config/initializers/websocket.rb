EM.next_tick do
  @channel = EM::Channel.new

  # Simulated messages
  #EM::PeriodicTimer.new(2) do
  #  random_string = rand(100_000).to_s
  #  @channel.push random_string
  #end

  @subscriptions = {}
  @sockets = Array.new
  @userlist = Array.new

  def sendMsg(socket, msg)
    socket.send msg
  end # /sendMsg

  def sendOnly(socket, msg)
    cmsg = "c" + msg
    sendMsg(socket, cmsg)
  end

  # c stands for message
  def sendAll(msg)
    cmsg = "c" + msg
    @sockets.each do |ws|
      sendMsg(ws, cmsg)
    end # /@sockets.each do
  end # /sendAll 
 
  # sends a msg to all users except ews
  def sendAllExcept(ews, msg)
    cmsg = "c" + msg
    @sockets.each do |ws|
      unless (ws.equal? ews)
        sendMsg(ws, cmsg)
      end # /unless ws.equal? ews
    end # /@sockets.each do
  end # /sendAllExcept

  # a stands for addclient
  def addClient(name)
    amsg = "a" + name
    @sockets.each do |ws|
      sendMsg(ws, amsg)
    end # /@sockets.each do
  end # /addClient

  # r stands for removeclient
  def removeClient
    @sockets.each do |ws|
      rmsg = "r"
      sendMsg(ws, rmsg);
      
      @userlist.each do |user|
        amsg = "a" + user
        sendMsg(ws, amsg)
      end # /@userlist.each do
    end # /@sockets.each do
  end # /removeClient



  EM::WebSocket.run(:host => '0.0.0.0', :port => 8080) do |ws|
    username = ""
    ws.onopen do
      subscriber_id = @channel.subscribe do |msg|
      end
      
      # subscriber_id = @channel.subscribe do |msg|
      #  ws.send msg
      # end

      @userlist.each do |user|
        amsg = "a" + user
        sendMsg(ws, amsg)
      end # /@userlist.each do

      sendOnly(ws, 'Please enter username in the space below:')

      @sockets.push ws
      @subscriptions[ws.signature] = subscriber_id
    end # /ws.onopen

    ws.onmessage do |msg|
      if username.blank? then
        
        if (@userlist.include? msg) then
          sendOnly(ws, "The username entered is already taken. Try again:")
        else
          username = msg
          @userlist.push username
          
          sendOnly(ws, "Welcome #{username}!")
         
          addClient username
          sendAllExcept(ws, "#{username} has entered the room.")
        end
      else
        sendAll('<b>' + username + '</b>: ' + msg)
      end # /username.blank? then
    
    end # /ws.onmessage

    ws.onclose do
      subscriber_id = @subscriptions.delete(ws.signature)
      @channel.unsubscribe subscriber_id

      @userlist.delete username
      @sockets.delete ws

      removeClient
      sendAll "#{username} has left the room."
    end # /ws.onclose
  
  end # /EM.websocket.run

end # /em.nextTick
