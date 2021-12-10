defmodule MyAppWeb.RegistrationController do
  use MyAppWeb, :controller
  plug Ueberauth

  alias MyApp.Accounts
  alias MyAppWeb.Authentication
  alias MyAppWeb.EmailConfirmationTokens

  def new(conn, params) do
    conn
    |> put_session(:register_redirect, Map.get(params, "after", ""))
    |> render(:new,
      changeset: Accounts.change_user(),
      action: Routes.registration_path(conn, :create)
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
            if(redirect_path,
              do: redirect_path,
              else: Routes.profile_path(conn, :show)
            )
        )

      {:error, changeset} ->
        render(conn, :new,
          changeset: changeset,
          action: Routes.registration_path(conn, :create)
        )
    end
  end
end
