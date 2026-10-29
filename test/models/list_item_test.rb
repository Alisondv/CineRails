require "test_helper"

class ListItemTest < ActiveSupport::TestCase
  test "pertence a um perfil e a um filme (belongs_to obrigatório)" do
    item = ListItem.new
    assert_not item.valid?
    assert item.errors.key?(:profile)
    assert item.errors.key?(:movie)
  end

  test "não deixa o mesmo filme duas vezes na lista do mesmo perfil" do
    duplicate = ListItem.new(profile: profiles(:ana), movie: movies(:matrix))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:movie_id], "já está na sua lista"
  end

  test "outro perfil pode salvar o mesmo filme" do
    assert ListItem.new(profile: profiles(:bruno), movie: movies(:matrix)).valid?
  end
end
