require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "é válido com nome e cor da paleta" do
    assert Profile.new(name: "Carla", color: Profile::COLORS.first).valid?
  end

  test "exige nome" do
    profile = Profile.new(name: "", color: Profile::COLORS.first)
    assert_not profile.valid?
    assert_includes profile.errors[:name], "não pode ficar em branco"
  end

  test "só aceita cores da paleta" do
    assert_not Profile.new(name: "Carla", color: "#123456").valid?
  end

  test "has_many :through devolve os filmes da Minha Lista" do
    assert_equal [ movies(:matrix) ], profiles(:ana).movies.to_a
  end

  test "in_list? aceita um Movie ou um tmdb_id" do
    ana = profiles(:ana)
    assert ana.in_list?(movies(:matrix))
    assert ana.in_list?(603)
    assert_not ana.in_list?(movies(:interstellar))
  end

  test "apagar o perfil apaga a lista e as avaliações (dependent: :destroy)" do
    assert_difference [ "ListItem.count", "Review.count" ], -1 do
      profiles(:ana).destroy
    end
  end
end
