defmodule MyApp.Accounts.PasswordResetToken do
  @moduledoc """
  Saves the token for the desire to reset a password.
  """
  use MyApp.Schema
  import Ecto.Changeset

  alias MyApp.Accounts.User

  schema "password_reset_tokens" do
    field :token, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def form_changeset do
    Ecto.Changeset.change(%__MODULE__{})
  end

  @doc false
  def changeset(password_reset_token, attrs) do
    password_reset_token
    |> cast(attrs, [:user_id])
    |> generate_token
    |> validate_required([:token, :user_id])
  end

  defp generate_token(changeset) do
    put_change(changeset, :token, MyApp.Helpers.random_string(16))
  end
end
