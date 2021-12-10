defmodule MyApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :admin, :boolean, null: false, default: false
      add :confirmed, :boolean, null: false, default: false
      add :encrypted_password, :string, null: false

      timestamps()
    end

    create unique_index(:users, :email)
  end
end
