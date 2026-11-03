# Conta de acesso; cada conta pode ter vários perfis.
class User < ApplicationRecord
  # has_secure_password: gera os métodos password=, password_confirmation= e
  # authenticate a partir da coluna password_digest (precisa da gem bcrypt,
  # ativada no Gemfile). Também já exige presença da senha na criação.
  has_secure_password

  # has_many: uma conta tem vários perfis ("Quem está assistindo?").
  # dependent: :destroy apaga os perfis (e, em cascata, as listas/avaliações
  # deles) junto com a conta, para não deixar perfil órfão no banco.
  has_many :profiles, dependent: :destroy

  # normalizes (Rails 7.1+): roda em toda escrita e leitura do atributo.
  # Garante que "Ana@Email.com " e "ana@email.com" sejam tratados como o mesmo
  # e-mail, tanto no cadastro quanto no login.
  normalizes :email, with: ->(email) { email.strip.downcase }

  # presence: obrigatório. uniqueness: não deixa duas contas com o mesmo e-mail
  # (a normalização acima garante que a comparação ignora maiúsculas/espaços).
  # format: usa a regex de e-mail que já vem com o Ruby, em vez de inventar uma.
  validates :email, presence: true, uniqueness: true,
                     format: { with: URI::MailTo::EMAIL_REGEXP, message: "não é um e-mail válido" }

  # allow_nil: o has_secure_password já exige senha na criação (validação própria);
  # esta validação só entra em ação quando alguém de fato tenta definir uma senha curta.
  validates :password, length: { minimum: 6 }, allow_nil: true
end
