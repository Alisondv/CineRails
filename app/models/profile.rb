# Perfil da tela "Quem está assistindo?" (sem senha própria: pertence a um User,
# e o id do perfil escolhido fica na sessão). Quem usa este model: ProfilesController
# (lista e cria perfis da conta logada), SessionsController (troca o perfil atual)
# e praticamente todo o resto do app, através de current_profile.
class Profile < ApplicationRecord
  # Cores disponíveis para o avatar (usadas no seed e nas validações).
  COLORS = %w[#e50914 #2563eb #16a34a #f59e0b #9333ea].freeze

  # belongs_to já é obrigatório por padrão no Rails (config.load_defaults 8.1):
  # não dá para salvar um perfil sem conta. É o que faz a tela de perfis
  # mostrar só os perfis de quem está logado (current_user.profiles).
  belongs_to :user

  # has_many: um perfil tem vários itens na lista e várias avaliações.
  # dependent: :destroy apaga os registros filhos junto com o perfil.
  has_many :list_items, dependent: :destroy
  has_many :reviews, dependent: :destroy

  # has_many :through: "pula" a tabela de junção.
  # profile.movies devolve direto os filmes da Minha Lista (SQL com JOIN em list_items).
  has_many :movies, through: :list_items

  validates :name, presence: true, length: { maximum: 20 }
  validates :color, inclusion: { in: COLORS }

  # Letra exibida dentro do avatar.
  def initial
    name.first.upcase
  end

  def in_list?(movie_or_tmdb_id)
    tmdb_id = movie_or_tmdb_id.respond_to?(:tmdb_id) ? movie_or_tmdb_id.tmdb_id : movie_or_tmdb_id
    movies.exists?(tmdb_id: tmdb_id)
  end
end
