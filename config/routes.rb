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
  namespace :reports do
    resources :theses, :only => [] do
      collection do
        get :unassigned_students
        get :supervisor_theses
        get :department_theses
        get :faculty_theses
        get :supervisors_theses_of_department
        get :supervisors_theses_of_faculty
      end
    end
  end


end
