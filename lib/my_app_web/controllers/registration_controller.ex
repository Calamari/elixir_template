defmodule MyAppWeb.RegistrationController do
  use MyAppWeb, :controller
  plug Ueberauth

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyAppWeb.Authentication
  alias MyAppWeb.EmailConfirmationTokens

  def new(conn, params) do
    conn
    |> put_session(:register_redirect, Map.get(params, "after", ""))
    |> render(:new,
      changeset: Accounts.change_user(%User{}),
      action: ~p"/register"
    )
  end

  def create(%{assigns: %{ueberauth_auth: auth_params}} = conn, _params) do
    case Accounts.register(auth_params) do
      {:ok, user} ->
        redirect_path = get_session(conn, :register_redirect)

        conn
        |> Authentication.log_in(user)
        |> delete_session(:register_redirect)
        |> EmailConfirmationTokens.send_mail_with_token(user)
        |> redirect(
          to:
            if(redirect_path == "" or redirect_path == nil,
              do: ~p"/me",
              else: redirect_path
            )
        )

      {:error, changeset} ->
        render(conn, :new,
          changeset: changeset,
          action: ~p"/register"
        )
    end
  end
end
