# Autenticação e seleção do perfil atual ficam centralizadas para todos os
# controllers. Os ids são armazenados na sessão assinada pelo Rails.
class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  before_action :require_login
  before_action :require_profile

  helper_method :current_user, :current_profile

  rescue_from TmdbClient::Error, with: :render_tmdb_error

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Busca o perfil pela conta atual para impedir acesso a perfis de outra conta.
  def current_profile
    @current_profile ||= current_user&.profiles&.find_by(id: session[:profile_id])
  end

  def require_login
    redirect_to new_user_session_path unless current_user
  end

  def require_profile
    redirect_to profiles_path unless current_profile
  end

  def tmdb
    @tmdb ||= TmdbClient.new
  end

  def render_tmdb_error(error)
    @error = error
    render "errors/tmdb", status: :service_unavailable
  end
end
