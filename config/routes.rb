Rails.application.routes.draw do
  devise_for :users

  root 'home#index'
  resources :clients do
    get :autocomplete_client_name, :on => :collection
    member do
      patch "reset_password"
    end
  end

  resources :brand_ambassadors do
    member do
      patch "reset_password"
    end
  end
  
  resources :locations

  resources :projects do
    resources :services do
      collection do
        get :autocomplete_location_name
        get :generate_select_ba
      end

      member do
        get :confirm_respond
        get :rejected_respond        
      end
    end
    get :autocomplete_client_name, :on => :collection
  end
  
  resources :ismp

  resources :reports do
    member do
      get :download_pdf
      get :print_pdf      
    end    
  end

  resources :default_values, only: [:edit, :update]
  resources :available_dates, only: [:index] do
    get :manage, :on => :collection
    post :manage, :on => :collection
    post :update_date, :on => :collection
  end

end
