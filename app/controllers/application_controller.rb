# Todos os controllers herdam daqui, então o que está neste arquivo vale para o app inteiro.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # before_action: roda ANTES de toda ação. Se ele fizer redirect,
  # a ação nem chega a executar. Aqui: sem perfil escolhido => tela de perfis.
  before_action :require_profile

  # helper_method deixa o método disponível também nas views (navbar, por exemplo).
  helper_method :current_profile

  # rescue_from: se QUALQUER ação levantar um erro do TMDB (token ausente,
  # token inválido, rede fora...), mostramos uma página amigável em vez de
  # uma tela de erro 500.
  rescue_from TmdbClient::Error, with: :render_tmdb_error

  private

  # O perfil "logado" é só um id guardado na sessão (cookie assinado).
  # ||= memoriza o resultado: a consulta ao banco é feita uma vez por requisição.
  def current_profile
    @current_profile ||= Profile.find_by(id: session[:profile_id])
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
