defmodule MyAppWeb.AuthorizationFallbackController do
  use MyAppWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(MyAppWeb.ErrorHTML)
    |> render(:"403")
  end
end
