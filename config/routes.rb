Diamond::Engine.routes.draw do

  resources :theses do
    resources :thesis_enrollments
    collection do
      delete :collection_destroy
      patch :collection_update
    end
  end



end
