# Um filme na "Minha Lista" de um perfil (tabela de junção).
class ListItem < ApplicationRecord
  # belongs_to: este registro guarda profile_id e movie_id.
  # No Rails 5+ o belongs_to já é obrigatório (valida presença) por padrão.
  belongs_to :profile
  belongs_to :movie

  # Validação de unicidade com escopo: o mesmo filme só uma vez por perfil.
  validates :movie_id, uniqueness: { scope: :profile_id, message: "já está na sua lista" }
end
