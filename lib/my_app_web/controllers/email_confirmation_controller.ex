defmodule MyAppWeb.EmailConfirmationController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyAppWeb.Authentication
  alias MyAppWeb.EmailConfirmationTokens

  def create(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> EmailConfirmationTokens.send_mail_with_token!(user)
    |> put_flash(:info, "Email confirmation sent to #{user.email}")
    |> redirect(to: ~p"/me")
  end

  def confirm(conn, %{
        "token" => token,
        "email" => email
      }) do
    case Accounts.confirm_email(email, token) do
      :ok ->
        redirect_target =
          case Authentication.get_current_user(conn) do
            nil -> ~p"/login"
            _ -> ~p"/me"
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
        nil -> ~p"/"
        _ -> ~p"/me"
      end

    conn
    |> put_flash(:error, "Given confirmation link is invalid or expired.")
    |> redirect(to: redirect_target)
  end
end
