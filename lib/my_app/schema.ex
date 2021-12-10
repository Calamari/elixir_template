defmodule Nioomi.Schema do
  @moduledoc """
  Common Schema definition that uses UUID as primary key.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
