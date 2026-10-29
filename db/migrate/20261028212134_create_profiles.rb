# Migration = "receita" versionada para alterar o banco.
# Foi gerada com: bin/rails g model Profile name:string color:string
# `bin/rails db:migrate` executa o método `change` e atualiza o db/schema.rb.
class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :name, null: false
      t.string :color, null: false, default: "#e50914"

      t.timestamps # cria created_at e updated_at automaticamente
    end
  end
end
