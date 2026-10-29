# Cache local MÍNIMO de um filme do TMDB.
# Só gravamos aqui os filmes que o usuário colocou na lista ou avaliou;
# todo o resto (catálogo, trailers, gêneros) vem da API em tempo real.
class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id, null: false
      t.string :title, null: false
      t.string :poster_path
      t.string :backdrop_path
      t.date :release_date
      t.text :overview

      t.timestamps
    end
    # Índice único: o banco também garante que um filme do TMDB não seja salvo duas vezes.
    add_index :movies, :tmdb_id, unique: true
  end
end
