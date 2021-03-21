Rails.application.routes.draw do

  resources :visitors, only: [:index]
  resources :distributors

  resources :rts do
    collection do
      post :import_insales
      get :unlinking_to_xls
    end
  end

  resources :drs do
    collection do
      post :import_insales
      get :unlinking_to_xls
    end
  end

  resources :products do
    collection do
      get :create_csv
      get :edit_multiple
      put :update_multiple
      post :delete_selected
      post :import
      get :import_insales_xml
      get :update_price_quantity_all_providers
      get :csv_param
      get :syncronaize
      get :linking
      get :export_api
    end
  end

  root to: 'distributors#index'
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  mount ActionCable.server => '/cable'
end
