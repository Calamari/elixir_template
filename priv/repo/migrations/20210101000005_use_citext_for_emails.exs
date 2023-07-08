defmodule Nioomi.Repo.Migrations.UseCitextForEmails do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :email, :citext
    end
  end

  def down do
    alter table(:users) do
      modify :email, :string
    end
  end
end
