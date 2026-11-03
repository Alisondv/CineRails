require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "é válido com e-mail e senha" do
    user = User.new(email: "carla@teste.com", password: "123456")
    assert user.valid?
  end

  test "normaliza o e-mail (tira espaços e deixa minúsculo)" do
    user = User.create!(email: "  Alison@UNAERP.edu.br  ", password: "123456")
    assert_equal "alison@unaerp.edu.br", user.email
  end

  test "authenticate aceita a senha certa e rejeita a errada" do
    user = User.create!(email: "login@teste.com", password: "123456")
    assert user.authenticate("123456")
    assert_not user.authenticate("senha-errada")
  end

  test "exige e-mail único (sem diferenciar maiúsculas/minúsculas, por causa da normalização)" do
    existente = users(:ana_conta)
    duplicado = User.new(email: existente.email.upcase, password: "123456")
    assert_not duplicado.valid?
    assert_includes duplicado.errors[:email], "já está em uso"
  end

  test "exige e-mail em formato válido" do
    user = User.new(email: "nao-e-email", password: "123456")
    assert_not user.valid?
    assert_includes user.errors[:email], "não é um e-mail válido"
  end

  test "exige senha com no mínimo 6 caracteres" do
    user = User.new(email: "outro@teste.com", password: "123")
    assert_not user.valid?
    assert_includes user.errors[:password], "é muito curto (mínimo: 6 caracteres)"
  end

  test "exige senha na criação" do
    user = User.new(email: "sem.senha@teste.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "não pode ficar em branco"
  end

  test "a fixture carrega com uma senha que autentica de verdade" do
    assert users(:ana_conta).authenticate("senha123")
  end
end
