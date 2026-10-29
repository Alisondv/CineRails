module ApplicationHelper
  # Círculo colorido com a inicial do perfil (avatar).
  def profile_avatar(profile, size: "w-10 h-10 text-lg")
    tag.span profile.initial,
             class: "#{size} inline-flex items-center justify-center rounded-md font-bold text-white",
             style: "background-color: #{profile.color}"
  end
end
