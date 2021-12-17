defmodule MyApp.EmailConfirmationTokens do
  @moduledoc """
  Context handling email confirmation tokens.
  """

  import Ecto.Query, warn: false

  alias MyApp.Accounts.EmailConfirmationToken
  alias MyApp.Repo

  # Use token within 10 minutes
  @max_age 10 * 60

  @doc """
  Gets a single token for user by email.

  Returns nil if there is no token for that email.

  ## Examples

      iex> get_by_email('foo@bar.com')
      %User{}

      iex> get_by_email('no@bar.com')
      nil

  """
  def get_by_email(email) do
    Repo.get_by(EmailConfirmationToken, email: email)
  end

  @doc """
  Creates a token for given email.

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %EmailConfirmationToken{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_token(String.t()) ::
          {:ok, EmailConfirmationToken.t()} | {:error, Ecto.Changeset.t()}
  def create_token(email) do
    %EmailConfirmationToken{}
    |> EmailConfirmationToken.changeset(%{email: email})
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :email)
  end

  @doc """
  Redeems a token for given email if existing.

  ## Examples

      iex> redeem_token(email, "666666")
      :ok

      iex> redeem_token(email, "123456")
      {:error, :token_not_valid}

  """
  @spec redeem_token(String.t(), String.t()) ::
          :ok
          | {:error, :token_not_valid}
          | {:error, :token_outdated}
          | {:error, :no_token_for_email}
  def redeem_token(email, wanted_token) do
    case Repo.get_by(EmailConfirmationToken, email: String.downcase(email)) do
      nil ->
        {:error, :no_token_for_email}

      token ->
        case token.token == wanted_token do
          true ->
            case NaiveDateTime.diff(NaiveDateTime.utc_now(), token.updated_at, :second) < @max_age do
              true ->
                Repo.delete(token)
                :ok

              _ ->
                {:error, :token_outdated}
            end

          _ ->
            {:error, :token_not_valid}
        end
    end
  end
end
