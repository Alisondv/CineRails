# Todos os controllers herdam daqui, então o que está neste arquivo vale para
# o app inteiro: toda requisição passa pelos before_actions abaixo antes de
# chegar na ação específica (HomeController#index, MoviesController#show...).
#
# session: um hash disponível em todo controller e view, que o Rails guarda
# num cookie assinado no navegador da pessoa (ele NÃO fica no banco). Tudo
# que a gente coloca em session[:algo] volta inteiro na próxima requisição
# dessa mesma pessoa, e some quando ela limpa os cookies ou troca de navegador.
# Aqui usamos pra lembrar qual conta e qual perfil estão "logados"
# (session[:user_id] e session[:profile_id]).
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # before_action: roda ANTES de toda ação, NA ORDEM declarada. Se um deles fizer
  # redirect, a ação nem chega a executar e os before_actions seguintes são pulados.
  # Por isso require_login vem antes de require_profile: sem conta logada não faz
  # sentido nem perguntar qual perfil usar.
  before_action :require_login
  before_action :require_profile

  # helper_method deixa o método disponível também nas views (navbar, por exemplo).
  helper_method :current_user, :current_profile

  # rescue_from: se QUALQUER ação levantar um erro do TMDB (token ausente,
  # token inválido, rede fora...), mostramos uma página amigável em vez de
  # uma tela de erro 500.
  rescue_from TmdbClient::Error, with: :render_tmdb_error

  private

  # A conta "logada" é só um id guardado na sessão (cookie assinado).
  # ||= memoriza o resultado: a consulta ao banco é feita uma vez por requisição.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # O perfil "logado" é só um id guardado na sessão (cookie assinado).
  # current_user.profiles (não Profile.find_by) garante que, mesmo que o
  # cookie da sessão seja adulterado com o id de um perfil de outra conta,
  # current_profile nunca aponta pra fora da conta logada.
  # &. (safe navigation): current_profile é chamado pelo layout em TODA
  # página, inclusive /login e /cadastro, onde current_user ainda é nil.
  def current_profile
    @current_profile ||= current_user&.profiles&.find_by(id: session[:profile_id])
  end

  def require_login
    redirect_to new_user_session_path unless current_user
  end

  def require_profile
    redirect_to profiles_path unless current_profile
  end

  # Atalho para os controllers: uma instância do service object.
  def tmdb
    @tmdb ||= TmdbClient.new
  end

  def render_tmdb_error(error)
    @error = error
    render "errors/tmdb", status: :service_unavailable
  end
end
