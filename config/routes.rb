Diamond::Engine.routes.draw do

  resources :thesis_messages, :only => [:update]
  resources :theses do
    member do
      patch :accept
      patch :revert_to_open
      get :change_history
    end
    collection do
      patch :collection_revert_to_open
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
        get :department_theses_stats, to: :department_theses_statistics
        get :faculty_theses_stats, to: :faculty_theses_statistics
        get :supervisors_theses_of_department
        get :supervisors_theses_of_faculty
      end
    end
  end


end
