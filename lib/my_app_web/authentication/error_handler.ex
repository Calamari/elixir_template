defmodule MyAppWeb.Authentication.ErrorHandler do
  @moduledoc """
  Handler for errors happening during guardian authentication.
  """
  use MyAppWeb, :controller

  alias MyAppWeb.Authentication.Plug

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, reason}, _opts) do
    conn =
      if reason == :token_expired do
        conn
        |> Plug.sign_out()
        |> put_flash(:error, "Session expired.")
      else
        put_flash(conn, :error, "You have to be logged in to access this resource.")
      end

    if conn.request_path != "/login" do
      redirect(conn, to: ~p"/login")
    else
      conn
    end
  end
end
