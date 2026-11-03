# Rotas: ligam "VERBO + URL" a "controller#ação".
# Rode `bin/rails routes` para ver a tabela completa que estas linhas geram.
Rails.application.routes.draw do
  # Página inicial (GET /) => HomeController#index
  root "home#index"

  # Cadastro de conta nova (e-mail + senha). GET mostra o formulário, POST cria.
  get  "cadastro", to: "registrations#new",    as: :new_registration
  post "cadastro", to: "registrations#create", as: :registration

  # Login/logout da CONTA (e-mail + senha). Não confundir com o `resource :session`
  # abaixo: aquele troca o PERFIL já dentro de uma conta logada; este entra/sai da conta.
  get    "login",  to: "user_sessions#new",     as: :new_user_session
  post   "login",  to: "user_sessions#create",  as: :user_session
  delete "logout", to: "user_sessions#destroy", as: :destroy_user_session

  # "Quem está assistindo?"  GET /profiles => ProfilesController#index
  # GET /profiles/new e POST /profiles => formulário "Adicionar perfil"
  resources :profiles, only: [ :index, :new, :create ]

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
