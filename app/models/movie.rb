# Cache local mínimo de um filme do TMDB.
# O catálogo inteiro vive na API; aqui só ficam os filmes que viraram
# "dado do usuário" (entraram numa lista ou receberam avaliação).
class Movie < ApplicationRecord
  has_many :list_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :profiles_in_list, through: :list_items, source: :profile

  validates :tmdb_id, presence: true, uniqueness: true
  validates :title, presence: true

  # Recebe o hash que veio do TMDB e devolve o Movie do banco,
  # criando o registro apenas se ele ainda não existir.
  def self.from_tmdb(data)
    find_or_create_by!(tmdb_id: data["id"]) do |movie|
      movie.title         = data["title"]
      movie.poster_path   = data["poster_path"]
      movie.backdrop_path = data["backdrop_path"]
      movie.release_date  = data["release_date"].presence
      movie.overview      = data["overview"]
    end
  end

  # Média das avaliações feitas no app (não a nota do TMDB).
  def average_rating
    reviews.average(:rating)&.round(1)
  end
end
