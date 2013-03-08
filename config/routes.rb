Chatroom::Application.routes.draw do
  get 'home/rubychat'
  root :to => 'home#rubychat'
end
