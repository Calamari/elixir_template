defmodule MyAppWeb.PasswordResetController do
  use MyAppWeb, :controller
  plug Ueberauth

  alias MyApp.Accounts
  alias MyApp.Accounts.PasswordResetToken
  alias MyApp.Email
  alias MyApp.Mailer

  def new(conn, _) do
    render(conn, :new,
      changeset: PasswordResetToken.form_changeset(),
      action: Routes.password_reset_path(conn, :create)
    )
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    case Accounts.get_by_email(email) do
      nil ->
        nil

      user ->
        case Accounts.create_password_reset_token_for_user(user) do
          {:ok, token} ->
            Email.password_reset_instructions_email(
              user,
              Routes.password_reset_url(conn, :redeem, token: token.token)
            )
            |> Mailer.deliver_later()

          _ ->
            nil
        end
    end

    conn
    |> put_flash(:success, "Password Reset Instructions Sent")
    |> redirect(to: Routes.password_reset_path(conn, :sent))
  end

  def sent(conn, _) do
    render(conn, :sent)
  end

  def redeem(conn, %{"token" => token}) do
    render(conn, :redeem,
      valid_token: Accounts.is_valid_password_reset_token(token),
      changeset: Accounts.User.password_changeset(),
      action: Routes.password_reset_path(conn, :do_redeem, token)
    )
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
      |> redirect(to: Routes.session_path(conn, :new))
    else
      {:error, changeset} ->
        render(conn, :redeem,
          valid_token: true,
          changeset: changeset,
          action: Routes.password_reset_path(conn, :do_redeem, token)
        )

      _ ->
        render(conn, :redeem, valid_token: false)
    end
  end
end
