# Tabela de junção entre Profile e Movie ("Minha Lista").
# `t.references` cria a coluna profile_id/movie_id, o índice e a foreign key.
class CreateListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :list_items do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
    # O mesmo filme não pode aparecer duas vezes na lista do mesmo perfil.
    add_index :list_items, [ :profile_id, :movie_id ], unique: true
  end
end
