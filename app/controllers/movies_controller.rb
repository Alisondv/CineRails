# Página de um filme. Mistura duas fontes de dados:
# - TMDB (detalhes e trailer), via service object;
# - nosso banco (avaliações feitas no app), via Active Record.
class MoviesController < ApplicationController
  # GET /movies/:id  (params[:id] é o id do filme no TMDB)
  def show
    @movie = tmdb.details(params[:id])
    @trailer_key = tmdb.trailer_key(params[:id])

    # Filme pode ainda não estar no banco (ninguém salvou/avaliou) => lista vazia.
    local_movie = Movie.find_by(tmdb_id: params[:id])
    @reviews = local_movie ? local_movie.reviews.recent.includes(:profile) : Review.none
    @average = local_movie&.average_rating

    # Formulário já preenchido se este perfil avaliou antes.
    @review = local_movie&.reviews&.find_by(profile: current_profile) || Review.new
  end
end
