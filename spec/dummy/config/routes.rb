Dummy::Application.routes.draw do
  resources :sessions

  resources :universes

  resources :users

  get '/fields_for', to: 'forms#fields_for'
  get '/selects', to: 'forms#selects'
  get '/inputs', to: 'forms#inputs'
  get '/actions', to: 'forms#actions'
  get '/data', to: 'forms#data'

end
