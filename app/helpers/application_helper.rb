# Helpers são métodos Ruby comuns, disponíveis em TODAS as views (não só
# nesta classe). Servem pra tirar lógica/formatação do HTML e deixar os
# templates mais legíveis — em vez de montar o avatar com HTML cru em cada
# view, cada uma chama profile_avatar(profile).
module ApplicationHelper
  # Círculo colorido com a inicial do perfil (avatar).
  def profile_avatar(profile, size: "w-10 h-10 text-lg")
    tag.span profile.initial,
             class: "#{size} inline-flex items-center justify-center rounded-md font-bold text-white",
             style: "background-color: #{profile.color}"
  end
end
