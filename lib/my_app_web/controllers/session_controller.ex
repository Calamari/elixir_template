defmodule MyAppWeb.SessionController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyAppWeb.Authentication

  def new(conn, _params) do
    if Authentication.get_current_user(conn) do
      redirect(conn, to: Routes.profile_path(conn, :show))
    else
      render(conn, :new,
        changeset: Accounts.change_user(),
        action: Routes.session_path(conn, :create)
      )
    end
  end

  def create(conn, %{"account" => %{"email" => email, "password" => password}}) do
    if Authentication.get_current_user(conn) do
      redirect(conn, to: Routes.profile_path(conn, :show))
    else
      case email |> Accounts.get_by_email() |> Authentication.authenticate(password) do
        {:ok, account} ->
          redirect_path =
            get_session(conn, :register_redirect) || Routes.profile_path(conn, :show)

          conn
          |> Authentication.log_in(account)
          |> delete_session(:register_redirect)
          |> redirect(to: redirect_path)

        {:error, :invalid_credentials} ->
          conn
          |> put_flash(:error, "Incorrect email or password")
          |> new(%{})
      end
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
