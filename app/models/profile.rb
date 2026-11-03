# Perfil de uma conta, usado para personalizar a lista e as avaliações.
class Profile < ApplicationRecord
  COLORS = %w[#e50914 #2563eb #16a34a #f59e0b #9333ea].freeze

  belongs_to :user

  has_many :list_items, dependent: :destroy
  has_many :reviews, dependent: :destroy

  has_many :movies, through: :list_items

  validates :name, presence: true, length: { maximum: 20 }
  validates :color, inclusion: { in: COLORS }

  def initial
    name.first.upcase
  end

  def in_list?(movie_or_tmdb_id)
    tmdb_id = movie_or_tmdb_id.respond_to?(:tmdb_id) ? movie_or_tmdb_id.tmdb_id : movie_or_tmdb_id
    movies.exists?(tmdb_id: tmdb_id)
  end
end
