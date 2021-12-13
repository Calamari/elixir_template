defmodule MyApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Accounts.PasswordResetToken
  alias MyApp.Accounts.User
  alias MyApp.EmailConfirmationTokens

  @doc """
  Returns the number of users.

  ## Examples

      iex> count_users()
      1

  """
  def count_users do
    Repo.aggregate(User, :count)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by email.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_by_email('foo@bar.com')
      %User{}

      iex> get_by_email('no@bar.com')
      nil

  """
  def get_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Just updates the password of a user.

  ## Examples

      iex> update_password_of_user(user, %{password: new_value, password_confirmation: new_value})
      {:ok, %User{}}

      iex> update_password_of_user(user, %{password: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_password_of_user(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user \\ %User{}, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Creates a password reset token for given user.
  """
  def create_password_reset_token_for_user(%User{} = user) do
    case Repo.get_by(PasswordResetToken, user_id: user.id) do
      nil -> %PasswordResetToken{}
      token -> token
    end
    |> PasswordResetToken.changeset(%{user_id: user.id})
    |> Repo.insert_or_update()
  end

  @five_minutes 5 * 60

  @doc """
  Returns true if given password reset token is valid that means less then 5 minutes old.

  ## Examples

      iex> is_valid_password_reset_token("random_string_token")
      true
  """
  def is_valid_password_reset_token(token_string) do
    case Repo.get_by(PasswordResetToken, token: token_string) do
      nil ->
        false

      # Timex.after?(token.updated_at, minutes: -5)
      token ->
        NaiveDateTime.diff(NaiveDateTime.utc_now(), token.updated_at, :second) < @five_minutes
    end
  end

  @doc """
  Returns PasswordResetToken if given password reset token is valid that means less then 5 minutes old.

  ## Examples

      iex> is_valid_password_reset_token("random_string_token")
      %PasswordResetToken{}

      iex> is_valid_password_reset_token("not_existing_token")
      nil
  """
  def get_valid_password_reset_token(token_string) do
    Repo.get_by(PasswordResetToken, token: token_string)
  end

  def delete_password_reset_token_for_user(%User{id: user_id}) do
    {count, _} = from(t in PasswordResetToken, where: t.user_id == ^user_id) |> Repo.delete_all()

    {:ok, count}
  end

  def register(%Ueberauth.Auth{} = params) do
    %User{}
    |> User.register_changeset(extract_user_params(params))
    |> Repo.insert()
  end

  def register(%{} = params) do
    %User{}
    |> User.register_changeset(params)
    |> Repo.insert()
  end

  @spec confirm_email(String.t(), String.t()) :: :ok | {:error, atom()}
  def confirm_email(email, token) do
    with :ok <- EmailConfirmationTokens.redeem_token(email, token),
         user <- get_by_email(email),
         {:ok, user} <- update_user_email_confirmation(user, true) do
      :ok
    else
      error ->
        error
    end
  end

  defp extract_user_params(%{credentials: %{other: other}, info: info}) do
    info
    |> Map.from_struct()
    |> Map.merge(other)
  end

  defp update_user_email_confirmation(user, value) do
    User.email_confirmation_changeset(user, %{confirmed: value}) |> Repo.update()
  end
end
