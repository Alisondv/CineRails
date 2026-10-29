# Tela "Quem está assistindo?".
class ProfilesController < ApplicationController
  # Esta é justamente a tela onde se escolhe o perfil, então pulamos a exigência.
  skip_before_action :require_profile

  def index
    @profiles = Profile.order(:id)
  end
end
