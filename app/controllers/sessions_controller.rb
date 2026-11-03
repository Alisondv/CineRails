# Escolhe/troca o perfil atual, dentro de uma conta já logada. Sem senha: só
# guardamos o id na sessão. Chamado pelo `resource :session` em config/routes.rb
# (POST /session escolhe, DELETE /session troca de perfil). Quem cria a conta
# e faz login é outro controller: UserSessionsController.
class SessionsController < ApplicationController
  skip_before_action :require_profile

  # POST /session
  def create
    # current_user.profiles.find (nunca Profile.find): se alguém adulterar o
    # profile_id no formulário para o id de um perfil de OUTRA conta, o find
    # não acha nada dentro de current_user.profiles e levanta RecordNotFound
    # (404) em vez de deixar a pessoa entrar no perfil de outra conta.
    profile = current_user.profiles.find(params[:profile_id])
    session[:profile_id] = profile.id
    redirect_to root_path
  end

  # DELETE /session
  def destroy
    session.delete(:profile_id)
    redirect_to profiles_path
  end
end
