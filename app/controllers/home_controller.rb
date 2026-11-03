# Dados exibidos na página inicial: destaque, listas gerais e gêneros.
class HomeController < ApplicationController
  GENRE_ROWS = [ 28, 35, 878 ].freeze

  def index
    trending = tmdb.trending
    @hero = trending.find { |movie| movie["backdrop_path"].present? }

    @rows = [
      { title: "Em alta", movies: trending },
      { title: "Populares", movies: tmdb.popular },
      { title: "Mais bem avaliados", movies: tmdb.top_rated }
    ]

    genre_names = tmdb.genres.to_h { |genre| [ genre["id"], genre["name"] ] }
    GENRE_ROWS.each do |genre_id|
      @rows << { title: genre_names[genre_id], movies: tmdb.by_genre(genre_id) }
    end
  end
end
