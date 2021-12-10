defmodule MyApp.Repo.Migrations.CreatePasswordResetTokens do
  use Ecto.Migration

  def change do
    create table(:password_reset_tokens) do
      add :token, :string, null: false
      add :user_id, references(:users), null: false, unique: true

      timestamps()
    end

    create unique_index(:password_reset_tokens, :user_id)
  end
end
