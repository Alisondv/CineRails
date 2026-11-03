class AddUserToProfiles < ActiveRecord::Migration[8.1]
  def change
    # add_reference: cria a coluna user_id, o índice e a foreign_key de uma vez.
    # null: false => todo perfil tem que pertencer a uma conta (casa com o
    # belongs_to :user, obrigatório por padrão, que vamos adicionar no model).
    add_reference :profiles, :user, null: false, foreign_key: true
  end
end
