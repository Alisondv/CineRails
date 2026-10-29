# Avaliação (1 a 5 estrelas) de um perfil para um filme.
class Review < ApplicationRecord
  belongs_to :profile
  belongs_to :movie

  validates :rating, presence: true,
                     numericality: { only_integer: true, in: 1..5 }
  validates :comment, length: { maximum: 500 } # opcional, mas com limite
  validates :movie_id, uniqueness: { scope: :profile_id, message: "já foi avaliado por este perfil" }

  # Scope = consulta reutilizável. Review.recent => mais novas primeiro.
  scope :recent, -> { order(created_at: :desc) }
end
