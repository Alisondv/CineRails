# Cadastro de conta nova. Quem se cadastra ainda não tem perfil, então a conta
# cai direto na tela "Quem está assistindo?", de onde pode criar um.
class RegistrationsController < ApplicationController
  # Estas ações são o próprio ponto de entrada: não tem conta nem perfil ainda.
  skip_before_action :require_login
  skip_before_action :require_profile

  # GET /cadastro
  def new
    @user = User.new
  end

  # POST /cadastro
  def create
    @user = User.new(registration_params)

    if @user.save
      # Cadastro já loga a pessoa: não faz sentido pedir e-mail/senha de novo.
      session[:user_id] = @user.id
      redirect_to profiles_path, notice: "Conta criada! Agora escolha ou crie um perfil."
    else
      # unprocessable_entity: mantém a tela de cadastro com os erros do @user.
      render :new, status: :unprocessable_entity
    end
  end

  private

  # strong parameters: só aceitamos estes três campos do formulário, nunca
  # o formulário inteiro (evita que alguém injete, por exemplo, um id de conta).
  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
