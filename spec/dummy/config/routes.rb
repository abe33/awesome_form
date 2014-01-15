Dummy::Application.routes.draw do
  resources :sessions

  resources :universes

  resources :users

  get '/fields_for', to: 'forms#fields_for'

end
