Rails.application.routes.draw do
  get 'game/new', to: 'game#create'
  get 'game/:id', to: 'game#show'
end
