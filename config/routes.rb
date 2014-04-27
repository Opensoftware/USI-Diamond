Diamond::Engine.routes.draw do

  resources :theses do
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
