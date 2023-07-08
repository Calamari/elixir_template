defmodule MyAppWeb.EmailConfirmationTokens do
  @moduledoc """
  Context handling email confirmation tokens.
  """
  use MyAppWeb, :controller

  alias MyApp.Accounts.EmailConfirmationToken
  alias MyApp.EmailConfirmationTokens
  alias MyApp.Mailer

  @doc """
  Creates a token and sends it via email to given user.
  """
  @spec send_mail_with_token(Plug.Conn.t(), MyApp.Accouts.User.t()) ::
          {:ok, EmailConfirmationToken.t()} | {:error, atom()}
  @spec send_mail_with_token(Plug.Conn.t(), MyApp.Accouts.User.t(), boolean()) ::
          {:ok, EmailConfirmationToken.t()} | {:error, atom()}
  def send_mail_with_token(conn, user, halt_on_error \\ false) do
    case EmailConfirmationTokens.create_token(user.email) do
      {:ok, token} ->
        MyApp.Email.email_confirmation_email(
          user,
          url(~p"/email/#{user.email}/confirmation/#{token.token}")
        )
        |> Mailer.deliver_later()

        conn

      {:error, error} ->
        # Should not happen, since email is already checked
        Honeybadger.notify(error)

        case halt_on_error do
          true ->
            conn
            |> put_status(500)
            |> text("Could not send confirmation email.")
            |> Plug.Conn.halt()

          _ ->
            conn
        end
    end
  end
end
