Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post :create, to:'games#create'
      put  :roll_ball, to: 'games#roll_ball'
      get :score, to: 'games#get_score'
    end
  end
end
