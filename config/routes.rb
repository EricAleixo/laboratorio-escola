Rails.application.routes.draw do
  get 'unidade_referencias/index'
  get 'unidade_referencias/show'
  get 'unidade_referencias/new'
  get 'unidade_referencias/create'
  get 'unidade_referencias/edit'
  get 'unidade_referencias/update'
  get 'unidade_referencias/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "application#index"
  
  # Rota para histórico de exames
  get "historico" => "application#historico", as: :historico
  
  # Rotas para análise de exames
  get "analise/exames" => "application#analise_exames", as: :analise_exames
  get "analise/emitidos" => "application#analise_emitidos", as: :analise_emitidos
  get "analise/aguardando" => "application#analise_aguardando", as: :analise_aguardando
  get "analise/tipos" => "application#analise_tipos", as: :analise_tipos
  
  resources :exames do
    resources :unidade_referencias
  end
  resources :unidade_medidas
  resources :pacientes do
    resources :exame_pacientes
  end
  resources :exame_pacientes
end
