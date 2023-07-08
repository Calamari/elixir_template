defmodule MyApp.Accounts.User do
  @moduledoc """
  Represents the User in the app.
  """
  use MyApp, :schema

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t(),
          admin: boolean(),
          confirmed: boolean(),
          email: String.t(),
          name: String.t(),
          password: String.t(),
          encrypted_password: String.t()
        }

  schema "users" do
    field :admin, :boolean, default: false
    field :confirmed, :boolean, default: false
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string

    timestamps()
  end

  @doc false
  def register_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password, required: true)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_encrypted_password
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:admin, :email, :name, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_encrypted_password
  end

  @doc false
  def email_confirmation_changeset(user, attrs) do
    user
    |> cast(attrs, [:confirmed])
    |> validate_required([:confirmed])
  end

  @doc false
  def password_changeset(user \\ %__MODULE__{}, attrs \\ %{}) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password, required: true)
    |> put_encrypted_password
  end

  defp put_encrypted_password(%{valid?: true, changes: %{password: pw}} = changeset) do
    put_change(
      changeset,
      :encrypted_password,
      Bcrypt.Base.hash_password(pw, Bcrypt.Base.gen_salt(12, true))
    )
  end

  defp put_encrypted_password(changeset), do: changeset
end
