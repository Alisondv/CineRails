# Helpers são métodos disponíveis nas views. Servem para tirar lógica de
# formatação do HTML e deixar os templates mais legíveis.
module TmdbHelper
  IMAGE_BASE_URL = "https://image.tmdb.org/t/p"

  # O TMDB devolve só o caminho ("/abc123.jpg"); a URL completa inclui o tamanho.
  def poster_url(path, size: "w500")
    "#{IMAGE_BASE_URL}/#{size}#{path}" if path.present?
  end

  def backdrop_url(path, size: "w1280")
    "#{IMAGE_BASE_URL}/#{size}#{path}" if path.present?
  end

  # "2024-05-17" (ou um Date) => "2024"
  def release_year(date)
    date.to_s.first(4).presence
  end

  # 135 => "2h 15min"
  def format_runtime(minutes)
    return if minutes.blank? || minutes.zero?

    hours, mins = minutes.divmod(60)
    hours.positive? ? "#{hours}h #{mins}min" : "#{mins}min"
  end
end
