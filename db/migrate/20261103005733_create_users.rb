# Tabela das contas (login com e-mail e senha). Veio depois das demais:
# até aqui o projeto não tinha login, só perfis soltos no banco.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # password_digest: coluna que o has_secure_password usa para guardar o
      # hash bcrypt da senha (nunca a senha em texto puro).
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    # Índice único: garante no banco (não só na validação do model) que não
    # existam duas contas com o mesmo e-mail, mesmo em caso de corrida entre requisições.
    add_index :users, :email, unique: true
  end
end
