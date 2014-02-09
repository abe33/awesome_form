Dummy::Application.routes.draw do
  resources :sessions

  resources :universes

  resources :users

  %w(fields_for selects inputs actions wrappers blocks data check_boxes radios with_errors placeholders hints).each do |r|
    get "/#{r}", to: "forms##{r}"
  end

end
