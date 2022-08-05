Rails.application.routes.draw do
  get 'search' => 'search#index', as: 'search'

  ## LOGIN AND OUT
  get 'logout' => 'sessions#destroy', as: 'logout'
  get 'login' => 'sessions#new', as:  'login'
  get 'login_as' => 'sessions#login_as', as: 'login_as'
  get 'back_to_my_login' => 'sessions#back_to_my_login', as: 'back_to_my_login'
  get 'invalid_login' => 'sessions#invalid_login', as: 'invalid_login'
  get 'unauthorized' => 'sessions#unauthorized', as: 'unauthorized'
  get 'inactive' => 'sessions#inactive', as: 'inactive_user'

  namespace :courses do
    resources :active, controller: 'active', only: %i[index show]
  end

  resource :reports, only: [:show] do
    get :requests
    get :items
  end

  resource :settings, only: %i[edit update] do
    get :cat_search, on: :member
    get :elastic_search
    get :primo_alma
    get :email
    get :item_request
    get :help
    get :acquisition_requests

    resources :subjects, module: :settings, controller: 'course_subjects', except: [:show]
    resources :faculties, module: :settings, controller: 'course_faculties', except: [:show]
  end

  resources :loan_periods
  resources :locations
  resources :courses
  resources :acquisition_requests do
    patch :change_status, on: :member
    post :send_to_acquisitions, on: :member
  end

  resources :users do
    collection do
      get :admin_users
    end

    member do
      post :change_role
      post :reactivate

      get :requests
    end

    get :staff, on: :new, action: :new_admin_user
  end

  namespace :search do
    resource :primo, only: %i[new create show], controller: 'primo'
  end

  resources :bib_finders do
    collection do
      get 'search_records'
      get 'search_primo'
    end
  end

  resources :requests, except: %i[new create] do
    member do
      get :change_status
      patch :change_owner
      get :archive
      post :assign
      get 'history' => 'request_history#index'
      post 'save_note' => 'request_history#create'
      post :rollover
      get :rollover_confirm
    end

    resource :copy_items, only: %i[show new create], module: 'requests'

    resources :items do
      member do
        get :change_status
        get :barcode
      end
    end
  end

  ## NEW REQUEST WIZARD
  get 'requests/new/step_one' => 'request_wizard#step_one', as: :new_request_step_one
  post 'requests/new/step_one/save' => 'request_wizard#save', as: :new_request_step_one_save
  get 'requests/new/step_two/:id' => 'request_wizard#step_two', as: :new_request_step_two
  post 'requests/new/finish/:id' => 'request_wizard#finish', as: :new_request_finish

  root 'home#index'
end
