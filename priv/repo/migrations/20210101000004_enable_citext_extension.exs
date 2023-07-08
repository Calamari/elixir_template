defmodule Nioomi.Repo.Migrations.EnableCitextExtension do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS citext")
  end

  def down do
    execute("DROP EXTENSION IF EXISTS citext")
  end
end
