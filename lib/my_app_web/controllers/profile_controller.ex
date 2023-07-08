defmodule MyAppWeb.ProfileController do
  use MyAppWeb, :controller

  def me(conn, _params) do
    render(conn, :me)
  end
end
