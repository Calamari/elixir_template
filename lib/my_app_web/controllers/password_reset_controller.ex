defmodule MyAppWeb.PasswordResetController do
  use MyAppWeb, :controller
  plug Ueberauth

  alias MyApp.Accounts
  alias MyApp.Accounts.PasswordResetToken
  alias MyApp.Accounts.Emails.PasswordResetInstructionsEmail
  alias MyApp.Mailer

  def new(conn, _) do
    render(conn, :new,
      changeset: PasswordResetToken.form_changeset(),
      action: ~p"/forgot_password"
    )
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    case Accounts.get_by_email(email) do
      nil ->
        nil

      user ->
        case Accounts.create_password_reset_token_for_user(user) do
          {:ok, token} ->
            PasswordResetInstructionsEmail.build(
              user,
              url(~p"/forgot_password/redeem?#{%{token: token.token}}")
            )
            |> Mailer.deliver_later()

          _ ->
            nil
        end
    end

    conn
    |> put_flash(:success, "Password Reset Instructions Sent")
    |> redirect(to: ~p"/forgot_password/sent")
  end

  def sent(conn, _) do
    render(conn, :sent)
  end

  def redeem(conn, %{"token" => token}) do
    if Accounts.password_reset_token_valid?(token) do
      render(conn, :redeem,
        token: token,
        changeset: Accounts.User.password_changeset(),
        action: "/forgot_password/redeem/#{token}"
      )
    else
      conn
      |> put_flash(:error, "The password reset token is invalid.")
      |> redirect(to: ~p"/login")
    end
  end

  def do_redeem(conn, %{
        "token" => token,
        "password_reset" => password_reset_params
      }) do
    with token when not is_nil(token) <- Accounts.get_valid_password_reset_token(token),
         user when not is_nil(user) <- Accounts.get_user(token.user_id),
         {:ok, _} <- Accounts.update_password_of_user(user, password_reset_params) do
      conn
      |> put_flash(:success, "Password was successfully changed!")
      |> redirect(to: ~p"/login")
    else
      {:error, changeset} ->
        render(conn, :redeem,
          token: token,
          changeset: changeset,
          action: "/forgot_password/redeem/#{token}"
        )

      _ ->
        conn
        |> put_flash(:error, "The password reset token is invalid.")
        |> redirect(to: ~p"/login")
    end
  end
end
