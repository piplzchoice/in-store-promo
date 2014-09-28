Rails.application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'

  devise_for :users,
    :controllers => {
      sessions: "sessions"
    }

  root 'home#index'
  resources :clients do
    get :autocomplete_client_name, :on => :collection
    member do
      patch "reset_password"
      delete "logged_as"
    end
  end

  resources :brand_ambassadors do
    member do
      patch "reset_password"
      delete "logged_as"
    end

    collection do
      get "view_ba_calender"
    end
  end

  resources :locations
  resources :email_templates, only: [:index, :edit, :update]

  resources :projects do
    resources :services do
      collection do
        get :autocomplete_location_name
        get :generate_select_ba
      end

      member do
        get :confirm_respond
        get :rejected_respond
        get :mark_service_as_complete
        patch :update_status_after_reported
      end
    end
    get :autocomplete_client_name, :on => :collection
    get :set_as_complete, :on => :member
    get :export_calendar, :on => :member
    get :print_calendar, :on => :member
  end

  resources :ismp do
    member do
      get :set_as_ba
      post :update_as_ba
    end
  end

  resources :reports do
    member do
      get :download_pdf
      get :print_pdf
    end

    collection do
      get :view_calendar
      get :reconcile_payments
      patch :update_service_paid
    end
  end

  resources :users, only: [:edit, :update]
  resources :default_values, only: [:edit, :update]
  resources :assignments, only: [:index, :show]
  resources :available_dates, only: [:index] do
    get :manage, :on => :collection
    post :manage, :on => :collection
    post :update_date, :on => :collection
  end

end
