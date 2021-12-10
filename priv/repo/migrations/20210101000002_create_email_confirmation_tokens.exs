defmodule MyApp.Repo.Migrations.AddEmailConfirmationTokens do
  use Ecto.Migration

  def change do
    create table(:email_confirmation_tokens) do
      add :email, :string, null: false
      add :token, :string, length: 32, null: false

      timestamps()
    end

    create unique_index(:email_confirmation_tokens, :email)
  end
end
