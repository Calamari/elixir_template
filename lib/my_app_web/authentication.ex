defmodule MyAppWeb.Authentication do
  @moduledoc """
  Implementation module for Guardian and functions for authentication.
  """
  use Guardian, otp_app: :my_app
  alias MyApp.{Accounts, Accounts.User}

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :resource_not_found}
      account -> {:ok, account}
    end
  end

  def log_in(conn, user) do
    __MODULE__.Plug.sign_in(conn, user)
  end

  def get_current_user(conn) do
    __MODULE__.Plug.current_resource(conn)
  end

  def log_out(conn) do
    __MODULE__.Plug.sign_out(conn)
  end

  def authenticate(%User{} = user, password) do
    authenticate(
      user,
      password,
      Bcrypt.verify_pass(password, user.encrypted_password)
    )
  end

  def authenticate(nil, password) do
    authenticate(nil, password, Bcrypt.no_user_verify())
  end

  defp authenticate(user, _password, true) do
    {:ok, user}
  end

  defp authenticate(_user, _password, false) do
    {:error, :invalid_credentials}
  end
end
