# Login e logout da conta. SessionsController troca o perfil atual.
class UserSessionsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_profile

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to profiles_path
    else
      flash.now[:alert] = "E-mail ou senha incorretos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_user_session_path
  end
end
