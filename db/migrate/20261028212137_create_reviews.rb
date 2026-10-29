class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.integer :rating, null: false # 1 a 5 estrelas (validado no model)
      t.text :comment                # opcional

      t.timestamps
    end
    # Cada perfil avalia um filme uma única vez.
    add_index :reviews, [ :profile_id, :movie_id ], unique: true
  end
end
