# Liga cada perfil a UMA conta. Antes desta migration, profiles era uma
# tabela solta (qualquer perfil aparecia pra qualquer pessoa); depois dela,
# "profile.user" existe e current_user.profiles passa a fazer sentido.
class AddUserToProfiles < ActiveRecord::Migration[8.1]
  def change
    return if column_exists?(:profiles, :user_id)

    add_reference :profiles, :user, null: true

    user_id = select_value("SELECT id FROM users ORDER BY id LIMIT 1")
    unless user_id
      now = connection.quote(Time.current)
      execute <<~SQL
        INSERT INTO users (email, password_digest, created_at, updated_at)
        VALUES ('legacy@cinerails.invalid', '!', #{now}, #{now})
      SQL
      user_id = select_value("SELECT id FROM users ORDER BY id LIMIT 1")
    end

    execute "UPDATE profiles SET user_id = #{connection.quote(user_id)} WHERE user_id IS NULL"
    change_column_null :profiles, :user_id, false
    add_foreign_key :profiles, :users
  end
end
