defmodule MyApp.Accounts.EmailConfirmationToken do
  @moduledoc """
  Represents the token that is used in confirming the user’s email.
  """
  use MyApp, :schema

  @type t() :: %__MODULE__{
          email: String.t(),
          token: String.t()
        }

  schema "email_confirmation_tokens" do
    field(:email, :string)
    field(:token, :string)

    timestamps()
  end

  @required_fields ~w[email]a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> downcase(:email)
    # |> unique_constraint(:email)
    |> generate_token
  end

  defp generate_token(changeset) do
    put_change(changeset, :token, MyApp.Helpers.random_string(16))
  end

  defp downcase(changeset, field) do
    update_change(changeset, field, &String.downcase/1)
  end
end
