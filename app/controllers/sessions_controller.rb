# Escolhe/troca o perfil atual. Sem senha: só guardamos o id na sessão.
class SessionsController < ApplicationController
  skip_before_action :require_profile

  # POST /session
  def create
    profile = Profile.find(params[:profile_id])
    session[:profile_id] = profile.id
    redirect_to root_path
  end

  # DELETE /session
  def destroy
    session.delete(:profile_id)
    redirect_to profiles_path
  end
end
