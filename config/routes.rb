Rails.application.routes.draw do
  get 'year/new'
  get 'year/edit'
  get 'templates/new'
  get 'templates/edit'
  get 'templatetypes/new'
  get 'templatetypes/create'
  get 'templatetypes/index'
  get 'templatetypes/edit'
  get 'templatetypes/update'
  get 'templatetypes/destory'
  get 'users/new'
  devise_for :users
  resources :sheets, only: [:update] do
    collection do
      put :sign_in_student, path: "sign_in_student/:id/:date"
      put :unsign_in_student, path: "unsign_in_student/:id/:date"
      delete :destroy_sheet, path: "destroy_sheet/:id/:date"
      post :create_sheet, path: "create_sheet/:id/:template_id/:date"
    end
  end
  resources :usertypes, except: [:show]
  resources :grades, except: [:show]
  resources :users, except: [:show] do
    collection do
      put :update_multiple
      get :archived, path: ":id/archived"
      post :import
    end
  end
  resources :templatetypes, except: [:show, :index]
  resources :templates do
    collection do
      post :add_schedule_date, path: "add_schedule_date/:id/:date"
      delete :delete_schedule_date, path: "delete_schedule_date/:id/:date"
    end
  end

  resources :years, except: [:show, :index]
  get 'users/students', to: 'users#index_student'
  get 'users/supervisors', to: 'users#index_supervisor'
  get 'users/:id', to: 'users#show'
  root to: 'dashboards#admin'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
