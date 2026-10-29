require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def build_review(**attrs)
    Review.new({ profile: profiles(:ana), movie: movies(:interstellar), rating: 5 }.merge(attrs))
  end

  test "é válida com nota de 1 a 5 e sem comentário" do
    assert build_review(comment: nil).valid?
  end

  test "nota é obrigatória" do
    assert_not build_review(rating: nil).valid?
  end

  test "nota fora de 1..5 é inválida" do
    assert_not build_review(rating: 0).valid?
    assert_not build_review(rating: 6).valid?
    assert_not build_review(rating: 3.5).valid?
  end

  test "comentário tem no máximo 500 caracteres" do
    assert_not build_review(comment: "a" * 501).valid?
  end

  test "um perfil avalia o mesmo filme só uma vez" do
    assert_not build_review(movie: movies(:matrix)).valid?
  end

  test "scope recent ordena da mais nova para a mais antiga" do
    reviews(:ana_matrix).update!(created_at: 1.day.ago)
    assert_equal reviews(:bruno_matrix), Review.recent.first
  end
end
