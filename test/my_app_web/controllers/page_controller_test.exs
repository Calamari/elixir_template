defmodule MyAppWeb.PageControllerTest do
  use MyAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hello MyApp"
  end
end
