require 'sidekiq/web'

Rails.application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end  

  devise_for :users,
    :controllers => {
      sessions: "sessions"
    }

  root 'home#index'
  resources :clients do
    resources :additional_personnels
    
    get :autocomplete_client_name, :on => :collection
    member do
      patch "reset_password"
      delete "logged_as"
      get "manage_addtional_emails"
      delete "remove_addtional_emails"
      post "update_addtional_emails"
    end

    post :export_calendar, :on => :member
    get :print_calendar, :on => :member

    resources :orders do
      member do
        put :update_status
        post :recurring
        post :archive
        post :add_location
        delete :remove_location
        post :add_product
        delete :removecopy
      end
    end

    resources :services do
      collection do
        get :autocomplete_location_name
        get :generate_select_ba
        get :generate_select_ba_tbs
        get :get_data_ids
        post :create_tbs
        post :confirm_inventory
        post :comment_inventory
        get :new_tbs
        get :new_order
        get :create_order
      end

      member do
        post :add_coop_demo
        post :request_by_phone
        post :request_by_email
        post :change_to_schedule
        get :confirm_respond
        get :rejected_respond
        get :mark_service_as_complete
        get :set_reschedule
        patch :update_status_after_reported
      end

      get "/logs/" => "services#logs"
      get "/log/:log_id" => "services#log", as: "show_log"
    end

    resources :products, only: [:create, :destroy, :index] do
      collection do
        get :get_product_by_client
      end
    end
  end

  resources :brand_ambassadors do
    member do
      get "availability"
    end
    resources :statements, :only => [:index, :show] do
      collection do
        get "download"
        post "export_data"
      end
    end

    member do
      patch "reset_password"
      delete "logged_as"
      get "new_location"
      post "create_location"
      delete "/destroy_location/:location_id" => "brand_ambassadors#destroy_location"
    end

    collection do
      get "view_ba_calender"
    end
  end

  resources :locations do
    collection do
      post :export_data
      post :import_data
      delete :deactive_data
      get :autocomplete_name
      get :get_all_name
      post :add_ba
    end
  end
  resources :email_templates, only: [:index, :edit, :update]

  resources :projects do

    get :autocomplete_client_name, :on => :collection
    get :set_as_complete, :on => :member
    post :export_calendar, :on => :member
    get :print_calendar, :on => :member
  end

  resources :ismp do
    member do
      get :set_as_ba
      post :update_as_ba
    end
  end

  resources :coordinator

  resources :reports do
    member do
      get :download_pdf
      get :print_pdf
    end

    collection do
      get :view_calendar
      get :reconcile_payments
      get :ba_payments
      post :new_ba_payments
      get :print_process_ba_payments
      patch :update_service_paid
      post :process_ba_payments
      get :export_data
      get :generate_export_data
      post "/upload/:key/" => "reports#upload_image",  as: "upload_picture"
      # get "upload/:key/" => "reports#upload_image",  as: "upload_picture_get"
      patch "/upload/:key/" => "reports#upload_image",  as: "upload_picture_patch"
      delete "/delete_upload/:key/:id" => "reports#delete_image"
    end
  end

  resources :invoices do
    post "new", :on => :collection, as: :new
    get :list, :on => :collection
    get :paid, :on => :collection
    get :print, :on => :member
    get :download, :on => :member
    patch :update_paid, :on => :member
    post "resend", :on => :member
  end

  resources :users, only: [:edit, :update]
  resources :default_values, only: [:edit, :update]
  resources :assignments, only: [:index, :show] do
    member do
      post "comment"
    end
  end
  resources :my_statements, only: [:index, :show] do
    collection do
      get "download"
      post "export_data"
    end
  end
  resources :available_dates, only: [:index] do
    get :manage, :on => :collection
    post :manage, :on => :collection
    post :update_date, :on => :collection
  end

  resources :territories

  get "/print/report/:id" => "print#report", as: "print_report_pdf"
  get "/print/invoice/:id" => "print#invoice", as: "print_invoice_pdf"
  get "/print/ba_payment/:id" => "print#ba_payment", as: "print_ba_payment_pdf"
  post "/forgot_password" => "home#forgot_password", as: "forgot_password"

end
