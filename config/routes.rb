Diamond::Engine.routes.draw do

  resources :thesis_messages, :only => [:update]
  resources :theses do
    member do
      patch :accept
      patch :revert_to_open
      get :change_history
    end
    resources :thesis_enrollments do
      member do
        get :accept
        get :reject
      end
    end
    collection do
      delete :collection_destroy
      patch :collection_update
    end
  end

end
