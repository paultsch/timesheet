Rails.application.routes.draw do
  resources :usertypes, except: [:show]
  resources :grades, except: [:show]

  root to: 'dashboards#admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
