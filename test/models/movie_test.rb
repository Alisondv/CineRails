require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "exige tmdb_id e título" do
    movie = Movie.new
    assert_not movie.valid?
    assert movie.errors.key?(:tmdb_id)
    assert movie.errors.key?(:title)
  end

  test "tmdb_id é único" do
    duplicate = Movie.new(tmdb_id: movies(:matrix).tmdb_id, title: "Outra Matrix")
    assert_not duplicate.valid?
  end

  test "from_tmdb cria o filme só uma vez" do
    data = { "id" => 27205, "title" => "A Origem", "poster_path" => "/x.jpg", "release_date" => "2010-07-15" }

    assert_difference "Movie.count", 1 do
      Movie.from_tmdb(data)
      Movie.from_tmdb(data) # segunda chamada encontra o registro existente
    end
    assert_equal Date.new(2010, 7, 15), Movie.find_by(tmdb_id: 27205).release_date
  end

  test "average_rating calcula a média das avaliações do app" do
    assert_equal 4.5, movies(:matrix).average_rating
    assert_nil movies(:interstellar).average_rating
  end

  test "associações com perfis e avaliações" do
    matrix = movies(:matrix)
    assert_includes matrix.profiles_in_list, profiles(:ana)
    assert_equal 2, matrix.reviews.count
  end
end
