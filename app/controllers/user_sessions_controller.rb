# Login e logout da CONTA (e-mail + senha). Chamado pelas rotas GET /login,
# POST /login e DELETE /logout (config/routes.rb). Não confundir com o
# SessionsController, que troca o PERFIL já dentro de uma conta logada.
class UserSessionsController < ApplicationController
  # Estas ações são o próprio ponto de entrada: não tem conta nem perfil ainda.
  skip_before_action :require_login
  skip_before_action :require_profile

  # GET /login
  def new
  end

  # POST /login
  def create
    user = User.find_by(email: params[:email])

    # &. (safe navigation): se não achou o e-mail, "user" é nil e não chama
    # authenticate (que daria erro em nil). authenticate devolve false se a
    # senha estiver errada, ou o próprio user se estiver certa.
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to profiles_path
    else
      # flash.now (em vez de flash): a mensagem aparece só nesta renderização,
      # porque não há redirect (continuamos na mesma tela de login).
      flash.now[:alert] = "E-mail ou senha incorretos."
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    # Limpa a conta E o perfil: continuar com um profile_id de outra conta
    # pendurado na sessão seria um furo de segurança.
    session.delete(:user_id)
    session.delete(:profile_id)
    redirect_to new_user_session_path
  end
end
