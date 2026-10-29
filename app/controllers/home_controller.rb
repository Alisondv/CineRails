# Home estilo streaming: banner + fileiras de filmes.
# Repare como o controller é enxuto: ele só PEDE os dados ao service (TmdbClient)
# e os entrega para a view em variáveis de instância (@...).
class HomeController < ApplicationController
  # Gêneros que viram fileiras (ids oficiais do TMDB).
  GENRE_ROWS = [ 28, 35, 878 ].freeze # Ação, Comédia, Ficção científica

  def index
    trending = tmdb.trending
    @hero = trending.find { |movie| movie["backdrop_path"].present? }

    @rows = [
      { title: "Em alta", movies: trending },
      { title: "Populares", movies: tmdb.popular },
      { title: "Mais bem avaliados", movies: tmdb.top_rated }
    ]

    # O nome de cada gênero também vem da API (já em português).
    genre_names = tmdb.genres.to_h { |genre| [ genre["id"], genre["name"] ] }
    GENRE_ROWS.each do |genre_id|
      @rows << { title: genre_names[genre_id], movies: tmdb.by_genre(genre_id) }
    end
  end
end
