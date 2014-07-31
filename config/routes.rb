Maxschedulerweb::Application.routes.draw do

  resources :job_loggings

  resources :operationhours

  resources :importdata

  root :to => 'sessions#new'
  
  match '/jobs/moveDownForm/', to: 'jobs#moveDownForm'
  
  resources :resources
  resources :boards
  resources :sites
  resources :users
  resources :maxschedulers
  resources :sessions, only: [:new, :create, :destroy]
  resources :usersites  
  resources :jobs
  resources :attributes   
  
  #match '/sites/set',  to: 'sites#set'
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  get "scheduler/showData"
  get "scheduler/jobData"
  get "scheduler/mx"
  get "scheduler/checkForJobDataUpdate"
  
  match '/test', to: 'boards#test'

  match '/importdata/:id/review', to: 'importdata#review'
  match '/importdata/:id/reviewDesktopScheduledJobs', to: 'importdata#reviewDesktopScheduledJobs'
  match '/importdata/:id/reviewDesktopListViewJobs', to: 'importdata#reviewDesktopListViewJobs'
  match '/importdata/:id/createjobs', to: 'importdata#createjobs'
  match '/importdata/:id/importScheduledJobs', to: 'importdata#importScheduledJobs'

  match '/maxschedulers/:id/populateData', to: 'maxschedulers#populateData'
  
  match '/jobs/asyncUpdate/:id', to: 'jobs#asyncUpdate'
  match '/jobs/asyncNew/', to: 'jobs#asyncNew'
  match '/jobs/asyncDelete/:id', to: 'jobs#asyncDelete'
  
  match ':controller(/:action(/:id))(.:format)'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
