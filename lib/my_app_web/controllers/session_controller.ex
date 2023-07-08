defmodule MyAppWeb.SessionController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyAppWeb.Authentication

  def new(conn, _params) do
    if Authentication.get_current_user(conn) do
      redirect(conn, to: ~p"/")
    else
      render(conn, :new, changeset: Accounts.change_user(%User{}))
    end
  end

  def create(conn, %{"account" => %{"email" => email, "password" => password}}) do
    if Authentication.get_current_user(conn) do
      # TODO: /me
      redirect(conn, to: ~p"/me")
    else
      case email
           |> Accounts.get_by_email()
           |> Authentication.authenticate(password) do
        {:ok, account} ->
          redirect_path = get_session(conn, :register_redirect)

          conn
          |> Authentication.log_in(account)
          |> delete_session(:register_redirect)
          |> redirect(
            to:
              if(redirect_path == "" or redirect_path == nil,
                do: ~p"/me",
                else: redirect_path
              )
          )

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
    |> redirect(to: ~p"/login")
  end
end
