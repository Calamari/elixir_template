defmodule MyAppWeb.EmailConfirmationController do
  use MyAppWeb, :controller

  alias MyAppWeb.Authentication
  alias MyApp.Accounts
  alias MyApp.Accounts.EmailConfirmationToken
  alias MyApp.EmailConfirmationTokens

  def create(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> MyAppWeb.EmailConfirmationTokens.send_mail_with_token(user, true)
    |> put_flash(:info, "Email confirmation sent to #{user.email}")
    |> redirect(to: Routes.profile_path(conn, :show))
  end

  def confirm(conn, %{
        "token" => token,
        "email" => email
      }) do
    case Accounts.confirm_email(email, token) do
      :ok ->
        redirect_target =
          case Authentication.get_current_user(conn) do
            nil -> Routes.session_path(conn, :new)
            _ -> Routes.profile_path(conn, :show)
          end

        conn
        |> put_flash(:info, "Congratulations. Email was successfully confirmed.")
        |> redirect(to: redirect_target)

      _ ->
        show_error(conn)
    end
  end

  def confirm(conn, _) do
    show_error(conn)
  end

  defp show_error(conn) do
    redirect_target =
      case Authentication.get_current_user(conn) do
        nil -> Routes.page_path(conn, :index)
        _ -> Routes.profile_path(conn, :show)
      end

    conn
    |> put_flash(:error, "Given confirmation link is invalid or expired.")
    |> redirect(to: redirect_target)
  end
end
