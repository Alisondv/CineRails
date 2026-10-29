# Service object que fala com a API do TMDB (https://developer.themoviedb.org).
#
# Por que um "service object"?
# - O controller fica enxuto: ele só pede "me dá os filmes populares".
# - Toda a parte de HTTP (URL, token, idioma, cache, erros) fica num lugar só.
# - Se um dia trocarmos de API, mexemos apenas neste arquivo.
#
# Uso: TmdbClient.new.popular  # => array de hashes de filmes
class TmdbClient
  BASE_URL = "https://api.themoviedb.org/3/" # a barra final faz o Faraday concatenar os caminhos

  # Por quanto tempo guardamos cada resposta no Rails.cache.
  CACHE_TTL = 6.hours

  # Erros próprios: o ApplicationController captura e mostra uma tela amigável.
  class Error < StandardError; end
  class MissingTokenError < Error; end

  # O token NUNCA fica no código. Lemos de (nesta ordem):
  #   1) variável de ambiente TMDB_TOKEN
  #   2) credentials criptografadas (bin/rails credentials:edit)
  def self.token
    ENV["TMDB_TOKEN"].presence || Rails.application.credentials.dig(:tmdb, :token).presence
  end

  def initialize(token: self.class.token)
    raise MissingTokenError, "Token do TMDB não configurado" if token.blank?
    @token = token
  end

  # ---- Listas para as fileiras da home ------------------------------------

  def trending
    get("trending/movie/week")["results"]
  end

  def popular
    get("movie/popular")["results"]
  end

  def top_rated
    get("movie/top_rated")["results"]
  end

  # "discover" filtra o catálogo; aqui, por gênero e ordenado por popularidade.
  def by_genre(genre_id)
    get("discover/movie", with_genres: genre_id, sort_by: "popularity.desc")["results"]
  end

  # Lista de gêneros: [{ "id" => 28, "name" => "Ação" }, ...]
  def genres
    get("genre/movie/list")["genres"]
  end

  # ---- Um filme -------------------------------------------------------------

  def details(id)
    get("movie/#{id}")
  end

  def videos(id, language: "pt-BR")
    get("movie/#{id}/videos", language: language)["results"]
  end

  # Muitos filmes não têm trailer dublado/legendado em pt-BR,
  # então tentamos em português e, se não houver, em inglês.
  # Devolve a "key" do YouTube (ex.: "dQw4w9WgXcQ") ou nil.
  def trailer_key(id)
    [ "pt-BR", "en-US" ].each do |language|
      trailer = videos(id, language: language).find do |video|
        video["site"] == "YouTube" && video["type"] == "Trailer"
      end
      return trailer["key"] if trailer
    end
    nil
  end

  # ---- Busca ----------------------------------------------------------------

  def search(query)
    return [] if query.blank?

    get("search/movie", query: query)["results"]
  end

  private

  # Todas as chamadas passam por aqui.
  #
  # Rails.cache.fetch(chave) { ... }:
  # - Se a chave já existe no cache (e não expirou), devolve o valor guardado
  #   e o bloco NEM é executado => nenhuma chamada HTTP.
  # - Se não existe, executa o bloco (chama a API), guarda o resultado por
  #   CACHE_TTL e devolve. Se o bloco levantar erro, nada é guardado.
  # Resultado: a home, que faz ~7 chamadas, fica rápida a partir da 2ª visita
  # e não gastamos o limite da API à toa.
  def get(path, params = {})
    params = { language: "pt-BR", region: "BR" }.merge(params)
    cache_key = "tmdb/#{path}?#{params.to_query}"

    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      connection.get(path, params).body
    end
  rescue Faraday::UnauthorizedError
    raise Error, "O TMDB recusou o token (401). Confira se você copiou o \"API Read Access Token\"."
  rescue Faraday::ResourceNotFound
    raise Error, "Filme não encontrado no TMDB."
  rescue Faraday::Error => e
    raise Error, "Não foi possível falar com o TMDB (#{e.class.name.demodulize})."
  end

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |f|
      f.request :authorization, "Bearer", @token # header Authorization: Bearer <token>
      f.response :json                           # converte o corpo JSON em Hash
      f.response :raise_error                    # status 4xx/5xx viram exceções
      f.options.timeout = 5                      # segundos
    end
  end
end
