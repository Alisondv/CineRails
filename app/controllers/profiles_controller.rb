# Tela "Quem está assistindo?" e o formulário "Adicionar perfil".
# Chamado pelas rotas GET /profiles, GET /profiles/new e POST /profiles
# (config/routes.rb). Escolher um perfil já existente é o SessionsController.
class ProfilesController < ApplicationController
  # Esta é justamente a tela onde se escolhe o perfil, então pulamos a exigência.
  skip_before_action :require_profile

  # GET /profiles
  def index
    # current_user.profiles (não Profile.order(:id)): cada conta só vê os
    # próprios perfis, nunca os de outra conta.
    @profiles = current_user.profiles.order(:id)
  end

  # GET /profiles/new
  def new
    @profile = current_user.profiles.new
  end

  # POST /profiles
  def create
    # current_user.profiles.new: o perfil já nasce ligado à conta logada,
    # então nem é possível alguém criar um perfil para a conta de outra pessoa.
    @profile = current_user.profiles.new(profile_params)

    if @profile.save
      # Depois de criar o perfil, já entra direto nele (igual escolher um existente).
      session[:profile_id] = @profile.id
      redirect_to root_path, notice: "Perfil criado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :color)
  end
end
