# Rotas: ligam "VERBO + URL" a "controller#ação".
# Rode `bin/rails routes` para ver a tabela completa que estas linhas geram.
Rails.application.routes.draw do
  # Página inicial (GET /) => HomeController#index
  root "home#index"

  # "Quem está assistindo?"  GET /profiles => ProfilesController#index
  resources :profiles, only: [ :index ]

  # Recurso SINGULAR (não tem id): só existe "a" sessão atual.
  #   POST   /session => SessionsController#create   (escolhe o perfil)
  #   DELETE /session => SessionsController#destroy  (troca de perfil)
  resource :session, only: [ :create, :destroy ]

  # GET /movies/:id => MoviesController#show  (o :id é o id do filme no TMDB)
  resources :movies, only: [ :show ] do
    # Rotas ANINHADAS: a URL já diz de qual filme estamos falando.
    #   POST   /movies/:movie_id/list_item => ListItemsController#create
    #   DELETE /movies/:movie_id/list_item => ListItemsController#destroy
    resource :list_item, only: [ :create, :destroy ]
    #   POST   /movies/:movie_id/reviews   => ReviewsController#create
    resources :reviews, only: [ :create ]
  end

  # Rotas com nome em português (o "as:" gera os helpers my_list_path e search_path).
  get "minha-lista", to: "list_items#index", as: :my_list
  get "busca", to: "search#index", as: :search

  # Health check usado por servidores/monitoramento.
  get "up" => "rails/health#show", as: :rails_health_check
end
