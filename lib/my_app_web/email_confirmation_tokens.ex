defmodule MyAppWeb.EmailConfirmationTokens do
  @moduledoc """
  Context handling email confirmation tokens.
  """
  use MyAppWeb, :controller

  alias MyApp.EmailConfirmationTokens
  alias MyApp.Mailer

  @doc """
  Creates a token and sends it via email to given user.
  """
  @spec send_mail_with_token(Plug.Conn.t(), MyApp.Accounts.User.t()) ::
          Plug.Conn.t()
  def send_mail_with_token(conn, user) do
    do_send_mail_with_token(conn, user)
    |> case do
      {_, conn} ->
        conn
    end
  end

  @doc """
  Creates a token and sends it via email to given user and halts connection with
  a 500 error if it fails.
  """
  @spec send_mail_with_token!(Plug.Conn.t(), MyApp.Accounts.User.t()) ::
          Plug.Conn.t()
  def send_mail_with_token!(conn, user) do
    do_send_mail_with_token(conn, user)
    |> case do
      {:ok, conn} ->
        conn

      {:error, conn} ->
        conn
        |> put_status(500)
        |> text("Could not send confirmation email.")
        |> Plug.Conn.halt()
    end
  end

  def do_send_mail_with_token(conn, user) do
    case EmailConfirmationTokens.create_token(user.email) do
      {:ok, token} ->
        MyApp.Email.email_confirmation_email(
          user,
          url(~p"/email/#{user.email}/confirmation/#{token.token}")
        )
        |> Mailer.deliver_later()

        {:ok, conn}

      {:error, error} ->
        # Should not happen, since email is already checked
        Honeybadger.notify(error)

        {:error, conn}
    end
  end
end
